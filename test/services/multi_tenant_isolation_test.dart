import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:safy/services/company_service.dart';
import 'package:safy/services/employee_service.dart';
import 'package:safy/services/enrollment_service.dart';
import 'package:safy/services/invite_service.dart';
import 'package:safy/services/subscription_service.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/subscription_model.dart';

/// マルチテナント分離検証(設計書 Step6: 「他社データが見えないことの確認は必須」)。
/// 実Firebaseの代わりにfake_cloud_firestoreを使い、companies/{companyId}配下の
/// サブコレクション構造そのものが他社データの越境アクセスを構造的に防ぐことを検証する。
void main() {
  late FakeFirebaseFirestore db;
  late CompanyService companyService;
  late EmployeeService employeeService;
  late EnrollmentService enrollmentService;
  late InviteService inviteService;
  late SubscriptionService subscriptionService;

  setUp(() {
    db = FakeFirebaseFirestore();
    companyService = CompanyService(db);
    employeeService = EmployeeService(db, MockFirebaseAuth());
    enrollmentService = EnrollmentService(db);
    inviteService = InviteService(db);
    subscriptionService = SubscriptionService(db);
  });

  group('マルチテナント分離: 社員一覧', () {
    test('A社の社員一覧にB社の社員が含まれない', () async {
      final companyA = await companyService.createCompany(
        name: 'A社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );
      final companyB = await companyService.createCompany(
        name: 'B社',
        industryId: 'construction',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );

      await db.doc('companies/${companyA.id}/employees/emp-a1').set({
        'companyId': companyA.id,
        'teamId': 't1',
        'displayName': 'A社の社員1',
        'role': 'member',
        'createdAt': DateTime(2026, 1, 1),
      });
      await db.doc('companies/${companyB.id}/employees/emp-b1').set({
        'companyId': companyB.id,
        'teamId': 't1',
        'displayName': 'B社の社員1',
        'role': 'member',
        'createdAt': DateTime(2026, 1, 1),
      });

      final employeesOfA =
          await employeeService.watchCompanyEmployees(companyA.id).first;

      expect(employeesOfA.length, 1);
      expect(employeesOfA.single.displayName, 'A社の社員1');
      expect(employeesOfA.any((e) => e.displayName == 'B社の社員1'), isFalse);
    });
  });

  group('マルチテナント分離: 受講記録', () {
    test('A社の受講記録取得でB社の受講記録が返らない', () async {
      final companyA = await companyService.createCompany(
        name: 'A社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );
      final companyB = await companyService.createCompany(
        name: 'B社',
        industryId: 'construction',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );

      await enrollmentService.startModule(
        companyId: companyA.id,
        employeeId: 'emp-a1',
        moduleId: 'm_ethics_sns',
      );
      await enrollmentService.startModule(
        companyId: companyB.id,
        employeeId: 'emp-b1',
        moduleId: 'm_security_basics',
      );

      final enrollmentsOfA =
          await enrollmentService.watchCompanyEnrollments(companyA.id).first;

      expect(enrollmentsOfA.length, 1);
      expect(enrollmentsOfA.single.employeeId, 'emp-a1');
      expect(enrollmentsOfA.any((e) => e.employeeId == 'emp-b1'), isFalse);
    });
  });

  group('マルチテナント分離: 招待コード', () {
    test('招待コードは発行元の会社IDのみを指し、他社IDには解決されない', () async {
      final companyA = await companyService.createCompany(
        name: 'A社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );
      final teamA = await inviteService.createTeam(
        companyId: companyA.id,
        teamName: '本社',
      );
      final code = await inviteService.issueInviteCode(
        companyId: companyA.id,
        teamId: teamA.id,
      );

      final resolved = await inviteService.resolveInviteCode(code.code);

      expect(resolved, isNotNull);
      expect(resolved!.companyId, companyA.id);
      expect(resolved.companyId, isNot('other-company-id'));
    });
  });

  group('マルチテナント分離: サブスクリプション', () {
    test('A社の契約情報取得でB社の契約が返らない', () async {
      final companyA = await companyService.createCompany(
        name: 'A社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );
      final companyB = await companyService.createCompany(
        name: 'B社',
        industryId: 'construction',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );

      await subscriptionService.upsertSubscription(
        companyId: companyA.id,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyA.id,
        subscribedModuleIds: ['m_ethics_sns'],
        fullSet: false,
        headcount: 20,
      );
      await subscriptionService.upsertSubscription(
        companyId: companyB.id,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyB.id,
        subscribedModuleIds: ['m_security_basics'],
        fullSet: false,
        headcount: 20,
      );

      final subscriptionOfA = await subscriptionService.getActiveSubscription(
        companyId: companyA.id,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyA.id,
      );

      expect(subscriptionOfA, isNotNull);
      expect(subscriptionOfA!.subscribedModuleIds, ['m_ethics_sns']);
      expect(subscriptionOfA.subscribedModuleIds.contains('m_security_basics'), isFalse);
    });

    test('B社の管理者がA社のownerIdで契約を検索しても取得できない(companyId境界も必須)', () async {
      final companyA = await companyService.createCompany(
        name: 'A社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );
      final companyB = await companyService.createCompany(
        name: 'B社',
        industryId: 'construction',
        planType: PlanType.team,
        contractedHeadcount: 20,
      );

      await subscriptionService.upsertSubscription(
        companyId: companyA.id,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyA.id,
        subscribedModuleIds: ['m_ethics_sns'],
        fullSet: false,
        headcount: 20,
      );

      // B社のパスでA社のownerIdを指定しても、companies/{companyB}/subscriptions配下には
      // 何も存在しないため取得できないことを確認する。
      final result = await subscriptionService.getActiveSubscription(
        companyId: companyB.id,
        ownerType: SubscriptionOwnerType.company,
        ownerId: companyA.id,
      );

      expect(result, isNull);
    });
  });
}
