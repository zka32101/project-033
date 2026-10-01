import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/dashboard_analytics.dart';
import 'package:safy/core/editor_stamp.dart';
import 'package:safy/core/required_modules.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/data/models/enrollment_model.dart';
import 'package:safy/features/admin/member_management/member_management_screen.dart';
import 'package:safy/features/admin/module_assignment/role_assignment_screen.dart';
import 'package:safy/providers/firebase_providers.dart';
import 'package:safy/providers/session_provider.dart';
import 'package:safy/services/company_service.dart';
import 'package:safy/services/member_admin_service.dart';

Employee _emp(String id, {String? jobRole, EmployeeRole role = EmployeeRole.member, String team = 't'}) => Employee(
      id: id,
      companyId: 'c1',
      teamId: team,
      displayName: id,
      role: role,
      createdAt: DateTime(2026, 1, 1),
      jobRole: jobRole,
    );

Company _company({List<String>? assigned, Map<String, List<String>> roles = const {}}) => Company(
      id: 'c1',
      name: 'テスト',
      industryId: 'retail',
      planType: PlanType.trial,
      contractedHeadcount: 5,
      customPassThreshold: const {},
      createdAt: DateTime(2026, 1, 1),
      assignedModuleIds: assigned,
      roleAssignments: roles,
    );

class _Session extends SessionNotifier {
  _Session(Employee actor, Company company) {
    state = SessionState(employee: actor, company: company);
  }
}

void main() {
  group('職種ごとの追加の必須', () {
    test('必須 = 全社共通 + チームの追加 + 職種の追加', () {
      expect(
        RequiredModules.forEmployee(companyAssigned: ['m1'], teamExtra: ['m2'], roleExtra: ['m3']),
        {'m1', 'm2', 'm3'},
      );
      expect(RequiredModules.forEmployee(companyAssigned: null, roleExtra: ['m3']), isNull);
    });

    test('ホームの必須表示: 職種の追加は常に必須', () {
      bool r(String id, {List<String>? company, List<String> role = const []}) => RequiredModules.isRequired(
            moduleId: id,
            companyAssigned: company,
            roleExtra: role,
            categoryHigh: false,
          );
      expect(r('m3', company: ['m1'], role: ['m3']), isTrue);
      expect(r('m3', company: ['m1']), isFalse);
      expect(r('m3', company: null, role: ['m3']), isTrue);
    });

    test('Companyの職種別の追加は保存・復元でき、未設定は空', () {
      final c = _company(roles: {'sales': ['m1', 'm2'], 'it': ['m3']});
      final back = Company.fromMap('c1', c.toMap());
      expect(back.roleAssignments, {'sales': ['m1', 'm2'], 'it': ['m3']});
      expect(Company.fromMap('c1', _company().toMap()).roleAssignments, isEmpty);
    });

    test('受講率は、職種の追加も含めた社員ごとの必須で集計される', () {
      Enrollment done(String e, String m) =>
          Enrollment(id: '$e-$m', employeeId: e, moduleId: m, status: EnrollmentStatus.completed);
      final company = _company(assigned: ['m1'], roles: {'sales': ['m2']});
      final sales = _emp('s', jobRole: 'sales');
      final other = _emp('o', jobRole: 'it');
      final stats = DashboardAnalytics.computeEmployeeCompletionStats(
        employees: [sales, other],
        enrollments: [done('s', 'm1'), done('o', 'm1'), done('o', 'm2')],
        totalModuleCount: 99,
        moduleIdsFor: (e) => RequiredModules.forEmployee(
          companyAssigned: company.assignedModuleIds,
          roleExtra: company.roleAssignments[e.jobRole] ?? const [],
        ),
      );
      expect(stats[0].totalModuleCount, 2); // 営業: m1 + m2
      expect(stats[0].completedCount, 1);
      expect(stats[1].totalModuleCount, 1); // IT: m1 のみ(m2は必須でないので数えない)
      expect(stats[1].completedCount, 1);
    });
  });

  group('サービス', () {
    test('職種の追加の必須の保存(スタンプ付き)と、管理者によるメンバーの職種設定', () async {
      final db = FakeFirebaseFirestore();
      await db.doc('companies/c1').set({'name': 'テスト'});
      await db.doc('companies/c1/employees/m1').set(_emp('m1').toMap());
      EditorStamp.uidProvider = () => 'admin1';
      addTearDown(() => EditorStamp.uidProvider = () => null);

      await CompanyService(db).updateRoleAssignedModules(companyId: 'c1', jobRoleId: 'sales', moduleIds: ['m1', 'm2']);
      final c = (await db.doc('companies/c1').get()).data()!;
      expect(c['roleAssignments'], {'sales': ['m1', 'm2']});
      expect(c['lastEditedBy'], 'admin1');

      final members = MemberAdminService(db);
      await members.setJobRole(companyId: 'c1', employeeId: 'm1', jobRoleId: 'accounting');
      expect((await db.doc('companies/c1/employees/m1').get()).data()!['jobRole'], 'accounting');
      expect((await db.doc('companies/c1/employees/m1').get()).data()!['lastEditedBy'], 'admin1');
      await members.setJobRole(companyId: 'c1', employeeId: 'm1', jobRoleId: null);
      expect((await db.doc('companies/c1/employees/m1').get()).data()!.containsKey('jobRole'), isFalse);
    });
  });

  group('RoleAssignmentScreen', () {
    Future<FakeFirebaseFirestore> seeded() async {
      final db = FakeFirebaseFirestore();
      await db.doc('companies/c1').set(_company(assigned: ['m1'], roles: {'sales': ['m2']}).toMap());
      await db.doc('industries/retail').set({
        'name': '小売',
        'highPriority': ['security'],
        'midPriority': <String>[],
        'lowPriority': ['compliance'],
      });
      for (final m in [('m1', '全社共通の研修', 'security'), ('m2', '営業だけの研修', 'compliance'), ('m3', 'その他', 'compliance')]) {
        await db.doc('modules/${m.$1}').set({
          'categoryId': m.$3,
          'title': m.$2,
          'description': '',
          'passThresholdDefault': 80,
          'isFreeTrial': false,
          'sortOrder': 1,
        });
      }
      return db;
    }

    testWidgets('職種ごとの追加件数が一覧に出て、選んで追加・保存できる', (tester) async {
      tester.view.physicalSize = const Size(900, 2800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await seeded();
      final admin = _emp('admin', role: EmployeeRole.admin);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(db),
          sessionProvider.overrideWith((ref) => _Session(admin, _company(assigned: ['m1'], roles: {'sales': ['m2']}))),
        ],
        child: const MaterialApp(home: RoleAssignmentScreen()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('追加の必須研修 1件'), findsOneWidget); // 営業
      expect(find.text('追加の必須研修なし'), findsNWidgets(6)); // 他の6職種

      await tester.tap(find.text('経理・財務'));
      await tester.pumpAndSettle();
      expect(find.text('経理・財務の必須研修'), findsOneWidget);
      CheckboxListTile tile(String t) => tester.widget(find.widgetWithText(CheckboxListTile, t, skipOffstage: false));
      expect(tile('全社共通の研修').onChanged, isNull); // 全社共通は外せない
      await tester.tap(find.widgetWithText(CheckboxListTile, 'その他'));
      await tester.pump();
      expect(find.text('経理・財務の追加: 1件'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'この内容で保存する'));
      await tester.pumpAndSettle();

      final saved = (await db.doc('companies/c1').get()).data()!['roleAssignments'] as Map;
      expect(saved['accounting'], ['m3']);
      expect(saved['sales'], ['m2']); // 他の職種の設定は変わらない
      expect(find.text('追加の必須研修 1件'), findsNWidgets(2)); // 営業 + 経理(一覧に反映)
    });

    testWidgets('管理者以外は使えない', (tester) async {
      final db = await seeded();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(db),
          sessionProvider.overrideWith((ref) => _Session(_emp('m'), _company())),
        ],
        child: const MaterialApp(home: RoleAssignmentScreen()),
      ));
      await tester.pumpAndSettle();
      expect(find.text('管理者のみ利用できます'), findsOneWidget);
    });
  });

  group('メンバー管理: 職種を設定する', () {
    testWidgets('管理者がメンバーの職種を選んで設定できる', (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = FakeFirebaseFirestore();
      await db.doc('companies/c1').set(_company().toMap());
      await db.doc('companies/c1/employees/admin').set(_emp('admin', role: EmployeeRole.admin).toMap());
      await db.doc('companies/c1/employees/sato').set(_emp('sato').toMap());

      await tester.pumpWidget(ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(db),
          sessionProvider.overrideWith((ref) => _Session(_emp('admin', role: EmployeeRole.admin), _company())),
        ],
        child: const MaterialApp(home: MemberManagementScreen()),
      ));
      await tester.pumpAndSettle();

      final row = find.widgetWithText(ListTile, 'sato');
      await tester.tap(find.descendant(of: row, matching: find.byType(PopupMenuButton<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('職種を設定する'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('営業'));
      await tester.pumpAndSettle();

      expect((await db.doc('companies/c1/employees/sato').get()).data()!['jobRole'], 'sales');
    });
  });
}
