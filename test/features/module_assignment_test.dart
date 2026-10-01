import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/dashboard_analytics.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/company_profile.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/data/models/enrollment_model.dart';
import 'package:safy/features/admin/module_assignment/module_assignment_screen.dart';
import 'package:safy/providers/firebase_providers.dart';
import 'package:safy/providers/session_provider.dart';

Company _company({CompanyProfile? profile, List<String>? assigned}) => Company(
      id: 'c1',
      name: 'テスト株式会社',
      industryId: 'retail',
      planType: PlanType.trial,
      contractedHeadcount: 5,
      customPassThreshold: const {},
      createdAt: DateTime(2026, 1, 1),
      profile: profile,
      assignedModuleIds: assigned,
    );

class _Session extends SessionNotifier {
  _Session(Company company) {
    state = SessionState(
      employee: Employee(
        id: 'e1',
        companyId: 'c1',
        teamId: 't',
        displayName: '管理者',
        role: EmployeeRole.admin,
        createdAt: DateTime(2026, 1, 1),
      ),
      company: company,
    );
  }
}

Future<FakeFirebaseFirestore> _seededDb() async {
  final db = FakeFirebaseFirestore();
  await db.doc('companies/c1').set(_company().toMap());
  await db.doc('industries/retail').set({
    'name': '小売・飲食',
    'highPriority': ['security'],
    'midPriority': <String>[],
    'lowPriority': ['privacy', 'infoMorals', 'infoManagement', 'compliance', 'aiUsage', 'mentalHealth', 'bcp', 'sustainability'],
  });
  Future<void> module(String id, String title, String category) => db.doc('modules/$id').set({
        'categoryId': category,
        'title': title,
        'description': '',
        'passThresholdDefault': 80,
        'isFreeTrial': false,
        'sortOrder': 1,
      });
  await module('m_security_basics', 'セキュリティの基本', 'security'); // 重点分野 → 推奨
  await module('m_law_company_vehicle', '社用車の安全運転管理', 'bcp'); // 社用車ありなら必須
  await module('m_ethics_sns', 'SNSの利用', 'infoMorals'); // 任意
  return db;
}

Widget _app(FakeFirebaseFirestore db, Company company, SessionNotifier Function() session) => ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(db),
        sessionProvider.overrideWith((ref) => session()),
      ],
      child: const MaterialApp(home: ModuleAssignmentScreen()),
    );

void main() {
  group('Company: 会社情報と受講対象', () {
    test('profileとassignedModuleIdsを保存・復元でき、未入力ならnull', () {
      final c = _company(
        profile: const CompanyProfile(
          employeeCount: 42,
          traits: {BusinessTrait.vehicles, BusinessTrait.aiUse},
        ),
        assigned: ['m1', 'm2'],
      );
      final back = Company.fromMap('c1', c.toMap());
      expect(back.profile!.employeeCount, 42);
      expect(back.profile!.traits, {BusinessTrait.vehicles, BusinessTrait.aiUse});
      expect(back.assignedModuleIds, ['m1', 'm2']);

      final empty = Company.fromMap('c1', _company().toMap());
      expect(empty.profile, isNull);
      expect(empty.assignedModuleIds, isNull);
    });

    test('法令の適用に使う従業員数は、会社情報があればそれ、なければ契約人数', () {
      expect(_company().legalEmployeeCount, 5);
      expect(_company(profile: const CompanyProfile(employeeCount: 80)).legalEmployeeCount, 80);
    });

    test('未知の特徴名は無視される', () {
      final p = CompanyProfile.fromMap({'employeeCount': 3, 'traits': ['vehicles', 'unknown']});
      expect(p.traits, {BusinessTrait.vehicles});
    });
  });

  group('DashboardAnalytics: 受講対象を絞った受講率', () {
    final employees = [
      Employee(
        id: 'a',
        companyId: 'c',
        teamId: 't',
        displayName: 'A',
        role: EmployeeRole.member,
        createdAt: DateTime(2026, 1, 1),
      ),
    ];
    Enrollment done(String m) => Enrollment(
          id: 'a-$m',
          employeeId: 'a',
          moduleId: m,
          status: EnrollmentStatus.completed,
        );

    test('moduleIdsForを指定すると、対象外の研修の修了は数えない', () {
      final stats = DashboardAnalytics.computeEmployeeCompletionStats(
        employees: employees,
        enrollments: [done('m1'), done('m2'), done('other')],
        totalModuleCount: 2,
        moduleIdsFor: (_) => {'m1', 'm2'},
      );
      expect(stats.single.completedCount, 2);
      expect(stats.single.completionRatePercent, 100);
    });

    test('指定なしなら従来どおり全修了を数える', () {
      final stats = DashboardAnalytics.computeEmployeeCompletionStats(
        employees: employees,
        enrollments: [done('m1'), done('other')],
        totalModuleCount: 4,
      );
      expect(stats.single.completedCount, 2);
    });
  });

  group('ModuleAssignmentScreen', () {
    testWidgets('推奨があらかじめチェックされ、社用車ありなら必須の研修もチェックされる', (tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await _seededDb();
      final company = _company(
        profile: const CompanyProfile(employeeCount: 20, traits: {BusinessTrait.vehicles}),
      );

      await tester.pumpWidget(_app(db, company, () => _Session(company)));
      await tester.pumpAndSettle();

      bool checked(String title) =>
          tester.widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, title, skipOffstage: false)).value!;
      expect(checked('セキュリティの基本'), isTrue); // 業種の重点分野
      expect(checked('社用車の安全運転管理'), isTrue); // 社用車 → 必須
      expect(checked('SNSの利用'), isFalse); // 任意
      expect(find.text('選択中: 2件 / 全3件'), findsOneWidget);
      expect(find.text('必須'), findsOneWidget);
    });

    testWidgets('必須の研修を外すと確認が出て、保存すると会社に指定が保存される', (tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await _seededDb();
      final company = _company(
        profile: const CompanyProfile(employeeCount: 20, traits: {BusinessTrait.vehicles}),
      );
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(db),
            sessionProvider.overrideWith((ref) => _Session(company)),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return const MaterialApp(home: ModuleAssignmentScreen());
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 必須(社用車)を外そうとすると確認が出る。「残す」で戻る。
      await tester.tap(find.widgetWithText(CheckboxListTile, '社用車の安全運転管理'));
      await tester.pumpAndSettle();
      expect(find.text('必須の研修を外しますか?'), findsOneWidget);
      await tester.tap(find.text('残す'));
      await tester.pumpAndSettle();
      expect(find.text('選択中: 2件 / 全3件'), findsOneWidget);

      // 任意の研修を足して保存する。
      await tester.tap(find.widgetWithText(CheckboxListTile, 'SNSの利用'));
      await tester.pump();
      expect(find.text('選択中: 3件 / 全3件'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'この内容で保存する(3件)'));
      await tester.pumpAndSettle();

      final saved = (await db.doc('companies/c1').get()).data()!['assignedModuleIds'] as List;
      expect(saved.toSet(), {'m_security_basics', 'm_law_company_vehicle', 'm_ethics_sns'});
      expect(container.read(sessionProvider).company!.assignedModuleIds!.length, 3);
    });

    testWidgets('「推奨に戻す」で、外した推奨がチェックされる', (tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await _seededDb();
      // 保存済みの指定は「SNSの利用」だけ。
      final company = _company(
        profile: const CompanyProfile(employeeCount: 20, traits: {BusinessTrait.vehicles}),
        assigned: ['m_ethics_sns'],
      );

      await tester.pumpWidget(_app(db, company, () => _Session(company)));
      await tester.pumpAndSettle();
      expect(find.text('選択中: 1件 / 全3件'), findsOneWidget);

      await tester.tap(find.text('推奨に戻す'));
      await tester.pumpAndSettle();
      expect(find.text('選択中: 2件 / 全3件'), findsOneWidget);
    });
  });
}
