import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:safy/services/company_service.dart';
import 'package:safy/services/content_service.dart';
import 'package:safy/services/employee_service.dart';
import 'package:safy/services/enrollment_service.dart';
import 'package:safy/services/invite_service.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/enrollment_model.dart';
import 'package:safy/data/models/quiz_attempt_model.dart';
import 'package:safy/data/seed/industries_seed.dart';
import 'package:safy/data/seed/modules_seed.dart';
import 'package:safy/core/category_priority_resolver.dart';
import 'package:safy/core/deadline_status.dart';
import 'package:safy/core/employee_module_progress.dart';
import 'package:safy/core/dashboard_analytics.dart';

/// 管理画面の「必要な教育内容の選択(業種プロファイル調整)」「合格ライン設定」
/// 「受講期限設定」「社員ごとの受講状況確認」が一連のフローとして正しく機能することを
/// 確認するサンプルテスト(実Firebase/Cloud Functionsの代わりにfake_cloud_firestoreを使用)。
void main() {
  late FakeFirebaseFirestore db;
  late CompanyService companyService;
  late ContentService contentService;
  late EmployeeService employeeService;
  late EnrollmentService enrollmentService;
  late InviteService inviteService;

  setUp(() async {
    db = FakeFirebaseFirestore();
    companyService = CompanyService(db);
    contentService = ContentService(db);
    employeeService = EmployeeService(db, MockFirebaseAuth());
    enrollmentService = EnrollmentService(db);
    inviteService = InviteService(db);

    // グローバルコンテンツ(業種・モジュール)を実際のシードデータで投入する
    // (bin/seed_firestore.dartが本番Firestoreへ行うのと同じデータ)。
    for (final industry in seedIndustries) {
      await db.collection('industries').doc(industry.id).set(industry.toMap());
    }
    for (final module in seedModules) {
      await db.collection('modules').doc(module.id).set(module.toMap());
    }
  });

  test('管理者が必要な教育内容・合格ライン・受講期限を設定し、社員の受講状況として反映される', () async {
    // ── 会社登録(建設業。既定では「情報モラル」は中優先度=任意) ──
    final company = await companyService.createCompany(
      name: 'テスト建設株式会社',
      industryId: 'construction',
      planType: PlanType.team,
      contractedHeadcount: 20,
    );
    final industry = (await contentService.getIndustry('construction'))!;

    const targetModuleId = 'm_ethics_sns'; // 情報モラルカテゴリの1つ目

    // 会社作成直後は業種の初期優先度どおり「情報モラル」は必須(高=2)ではない
    final defaultPriority = CategoryPriorityResolver.resolve(
      industry: industry,
      categoryId: seedModules.firstWhere((m) => m.id == targetModuleId).categoryId,
      overrides: company.categoryPriorityOverride,
    );
    expect(defaultPriority, isNot(2));

    // ── 1. 管理者が「必要な教育内容」を選ぶ: 情報モラルを高優先度(必須)に変更 ──
    await companyService.updateCategoryPriorityOverride(
      companyId: company.id,
      categoryId: 'infoMorals',
      priority: 2,
    );

    // ── 2. 管理者が対象モジュールの合格ラインを90%に設定 ──
    await companyService.updateModulePassThreshold(
      companyId: company.id,
      moduleId: targetModuleId,
      threshold: 90,
    );

    // ── 3. 管理者が対象モジュールの受講期限を設定 ──
    final dueDate = DateTime.now().add(const Duration(days: 10));
    await companyService.updateModuleDeadline(
      companyId: company.id,
      moduleId: targetModuleId,
      dueDate: dueDate,
    );

    final updatedCompany = (await companyService.getCompany(company.id))!;

    // 設定が正しく保存されていること
    expect(updatedCompany.categoryPriorityOverride['infoMorals'], 2);
    expect(
      updatedCompany.passThresholdFor(targetModuleId, moduleDefault: 80),
      90,
    );
    expect(updatedCompany.deadlineFor(targetModuleId), isNotNull);

    // 管理者が「必須」にしたカテゴリは、社員向けの必須/任意判定にも反映される
    // (home_screen.dartの必須バッジ判定と同じロジック)
    final resolvedPriority = CategoryPriorityResolver.resolve(
      industry: industry,
      categoryId: seedModules.firstWhere((m) => m.id == targetModuleId).categoryId,
      overrides: updatedCompany.categoryPriorityOverride,
    );
    expect(resolvedPriority, 2, reason: '管理者が必須指定したカテゴリのモジュールは必須(優先度2)として扱われるべき');

    // 期限設定は、まだ未受講の場合「期限間近」と判定される(10日後・reminderWindow=3日超なのでok)
    final deadlineStatusBeforeDue = DeadlineStatusEvaluator.evaluate(
      dueDate: updatedCompany.deadlineFor(targetModuleId),
      isCompleted: false,
      now: DateTime.now(),
    );
    expect(deadlineStatusBeforeDue, DeadlineStatus.ok);

    // ── 社員が招待コードで参加し、対象モジュールを受講する ──
    final team = await inviteService.createTeam(companyId: company.id, teamName: '本社');
    final invite =
        await inviteService.issueInviteCode(companyId: company.id, teamId: team.id);
    final resolvedInvite = await inviteService.resolveInviteCode(invite.code);
    expect(resolvedInvite, isNotNull);

    final employee = await employeeService.joinViaInviteCode(
      companyId: company.id,
      teamId: resolvedInvite!.teamId,
      displayName: '山田太郎',
    );

    await enrollmentService.startModule(
      companyId: company.id,
      employeeId: employee.id,
      moduleId: targetModuleId,
    );

    // クイズ受験(Cloud Functions `submitQuizAttempt` が本番では書き込む内容を模擬)。
    // 合格ライン90%に対しスコア85%→不合格のケース。
    final failingAttempt = QuizAttempt.evaluate(
      id: 'attempt-1',
      employeeId: employee.id,
      moduleId: targetModuleId,
      selectedAnswers: const [0, 1, 0, 1, 0, 1, 0, 1, 0, 0],
      correctIndexes: const [0, 1, 0, 1, 0, 1, 0, 1, 1, 1],
      thresholdApplied: updatedCompany.passThresholdFor(
        targetModuleId,
        moduleDefault: 80,
      ),
      answeredAt: DateTime.now(),
    );
    expect(failingAttempt.passed, isFalse, reason: '合格ライン90%に対し80%は不合格のはず');
    await db
        .doc('companies/${company.id}/quizAttempts/${failingAttempt.id}')
        .set(failingAttempt.toMap());

    // ── 4. 管理者が社員ごとの受講状況(モジュール別ステータス・点数)を確認できる ──
    final modules = await contentService.listModulesForIndustry(
      industry,
      categoryPriorityOverride: updatedCompany.categoryPriorityOverride,
    );
    final enrollments =
        await enrollmentService.watchEmployeeEnrollments(company.id, employee.id).first;
    final attempts = [failingAttempt];

    final progress = EmployeeModuleProgressBuilder.build(
      modules: modules,
      enrollments: enrollments,
      attempts: attempts,
    );
    final targetProgress = progress.firstWhere((p) => p.module.id == targetModuleId);

    expect(targetProgress.status, EnrollmentStatus.inProgress);
    expect(targetProgress.latestScore, 80);
    expect(targetProgress.latestPassed, isFalse);
    expect(targetProgress.attemptCount, 1);

    // 管理者ダッシュボードの全社集計にも(未完了として)反映される
    final stats = DashboardAnalytics.computeEmployeeCompletionStats(
      employees: [employee],
      enrollments: enrollments,
      totalModuleCount: modules.length,
    );
    expect(stats.single.completedCount, 0);

    // ── 再受験して合格ライン90%を満たし、モジュールを完了する ──
    final passingAttempt = QuizAttempt.evaluate(
      id: 'attempt-2',
      employeeId: employee.id,
      moduleId: targetModuleId,
      selectedAnswers: const [0, 1, 0, 1, 0, 1, 0, 1, 1, 1],
      correctIndexes: const [0, 1, 0, 1, 0, 1, 0, 1, 1, 1],
      thresholdApplied: updatedCompany.passThresholdFor(
        targetModuleId,
        moduleDefault: 80,
      ),
      answeredAt: DateTime.now(),
    );
    expect(passingAttempt.passed, isTrue);
    await db
        .doc('companies/${company.id}/quizAttempts/${passingAttempt.id}')
        .set(passingAttempt.toMap());
    await enrollmentService.completeModuleForEmployee(
      companyId: company.id,
      employeeId: employee.id,
      moduleId: targetModuleId,
    );

    final finalEnrollments =
        await enrollmentService.watchEmployeeEnrollments(company.id, employee.id).first;
    final finalAttempts = [failingAttempt, passingAttempt];
    final finalProgress = EmployeeModuleProgressBuilder.build(
      modules: modules,
      enrollments: finalEnrollments,
      attempts: finalAttempts,
    );
    final finalTargetProgress =
        finalProgress.firstWhere((p) => p.module.id == targetModuleId);

    expect(finalTargetProgress.status, EnrollmentStatus.completed);
    expect(finalTargetProgress.latestScore, 100);
    expect(finalTargetProgress.latestPassed, isTrue);
    expect(finalTargetProgress.attemptCount, 2);

    final finalStats = DashboardAnalytics.computeEmployeeCompletionStats(
      employees: [employee],
      enrollments: finalEnrollments,
      totalModuleCount: modules.length,
    );
    expect(finalStats.single.completedCount, 1);
    expect(finalStats.single.completionRatePercent, greaterThan(0));
  });
}
