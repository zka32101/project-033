import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/features/admin/member_management/member_management_screen.dart';
import 'package:safy/providers/firebase_providers.dart';
import 'package:safy/providers/session_provider.dart';
import 'package:safy/services/employee_service.dart';
import 'package:safy/services/member_admin_service.dart';

Employee _emp(String id, String name, {EmployeeRole role = EmployeeRole.member, bool deactivated = false}) =>
    Employee(
      id: id,
      companyId: 'c1',
      teamId: 't',
      displayName: name,
      role: role,
      createdAt: DateTime(2026, 9, 1),
      deactivated: deactivated,
    );

class _Session extends SessionNotifier {
  _Session(Employee actor) {
    state = SessionState(
      employee: actor,
      company: Company(
        id: 'c1',
        name: 'テスト',
        industryId: 'retail',
        planType: PlanType.trial,
        contractedHeadcount: 5,
        customPassThreshold: const {},
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }
}

Future<FakeFirebaseFirestore> _db() async {
  final db = FakeFirebaseFirestore();
  Future<void> put(Employee e) => db.doc('companies/c1/employees/${e.id}').set(e.toMap());
  await put(_emp('a1', '管理者A', role: EmployeeRole.admin));
  await put(_emp('m1', '佐藤'));
  await put(_emp('m2', '鈴木'));
  await put(_emp('x1', '退職者', deactivated: true));
  return db;
}

void main() {
  group('MemberGuard', () {
    final admin = _emp('a1', 'A', role: EmployeeRole.admin);
    final admin2 = _emp('a2', 'B', role: EmployeeRole.admin);
    final member = _emp('m1', 'M');
    final gone = _emp('a3', 'C', role: EmployeeRole.admin, deactivated: true);

    test('管理者が1人だけなら、降格も無効化もできない', () {
      final members = [admin, member];
      expect(MemberGuard.whyCannotDemote(members, admin), isNotNull);
      expect(MemberGuard.whyCannotDeactivate(members, admin, actorId: 'm1'), isNotNull);
    });

    test('管理者が2人いれば、降格も無効化もできる', () {
      final members = [admin, admin2, member];
      expect(MemberGuard.whyCannotDemote(members, admin), isNull);
      expect(MemberGuard.whyCannotDeactivate(members, admin2, actorId: 'a1'), isNull);
    });

    test('無効化された管理者は、管理者の人数に数えない', () {
      expect(MemberGuard.activeAdminCount([admin, gone, member]), 1);
      expect(MemberGuard.whyCannotDemote([admin, gone], admin), isNotNull);
    });

    test('自分自身は無効化できない。メンバーの無効化は常にできる', () {
      final members = [admin, admin2, member];
      expect(MemberGuard.whyCannotDeactivate(members, admin, actorId: 'a1'), isNotNull);
      expect(MemberGuard.whyCannotDeactivate(members, member, actorId: 'a1'), isNull);
    });
  });

  group('MemberAdminService / EmployeeService', () {
    test('役割の変更と無効化がFirestoreに反映され、一覧には無効化済みも含まれる', () async {
      final db = await _db();
      final service = MemberAdminService(db);

      await service.setRole(companyId: 'c1', employeeId: 'm1', role: EmployeeRole.admin);
      await service.deactivate(companyId: 'c1', employeeId: 'm2');

      final members = await service.watchMembers('c1').first;
      expect(members.length, 4);
      expect(members.firstWhere((m) => m.id == 'm1').role, EmployeeRole.admin);
      final m2 = members.firstWhere((m) => m.id == 'm2');
      expect(m2.deactivated, isTrue);
      expect((await db.doc('companies/c1/employees/m2').get()).data()!['deactivatedAt'], isNotNull);
    });

    test('受講率などに使う社員一覧(watchCompanyEmployees)は、無効化された社員を含まない', () async {
      final db = await _db();
      final active = await EmployeeService(db, MockFirebaseAuth()).watchCompanyEmployees('c1').first;
      expect(active.map((e) => e.id).toSet(), {'a1', 'm1', 'm2'});
    });

    test('Employeeのdeactivatedは保存・復元できる', () {
      expect(Employee.fromMap('x', _emp('x', 'X', deactivated: true).toMap()).deactivated, isTrue);
      expect(Employee.fromMap('x', _emp('x', 'X').toMap()).deactivated, isFalse);
    });
  });

  group('MemberManagementScreen', () {
    Widget app(FakeFirebaseFirestore db, Employee actor) => ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(db),
            sessionProvider.overrideWith((ref) => _Session(actor)),
          ],
          child: const MaterialApp(home: MemberManagementScreen()),
        );

    testWidgets('利用中の人数と上限、無効化されたメンバーが表示される', (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await _db();

      await tester.pumpWidget(app(db, _emp('a1', '管理者A', role: EmployeeRole.admin)));
      await tester.pumpAndSettle();

      expect(find.text('利用中 3名 / 上限 5名'), findsOneWidget);
      expect(find.text('管理者A(あなた)'), findsOneWidget);
      expect(find.text('無効化されたメンバー(1名)'), findsOneWidget);
      expect(find.text('退職者'), findsOneWidget);
    });

    testWidgets('メンバーを管理者にすると、役割が保存される', (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await _db();

      await tester.pumpWidget(app(db, _emp('a1', '管理者A', role: EmployeeRole.admin)));
      await tester.pumpAndSettle();

      // 佐藤の行のメニューを開く
      final row = find.widgetWithText(ListTile, '佐藤');
      await tester.tap(find.descendant(of: row, matching: find.byType(PopupMenuButton<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('管理者にする'));
      await tester.pumpAndSettle();
      expect(find.text('管理者にしますか?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, '管理者にする'));
      await tester.pumpAndSettle();

      expect((await db.doc('companies/c1/employees/m1').get()).data()!['role'], 'admin');
    });

    testWidgets('最後の管理者は降格できず、理由が表示される。保存も変わらない', (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await _db();

      await tester.pumpWidget(app(db, _emp('a1', '管理者A', role: EmployeeRole.admin)));
      await tester.pumpAndSettle();

      final row = find.widgetWithText(ListTile, '管理者A(あなた)');
      await tester.tap(find.descendant(of: row, matching: find.byType(PopupMenuButton<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('メンバーにする'));
      await tester.pumpAndSettle();

      expect(find.textContaining('管理者が1人だけ'), findsOneWidget);
      expect((await db.doc('companies/c1/employees/a1').get()).data()!['role'], 'admin');
    });

    testWidgets('メンバーを無効化すると、確認のうえ無効化され、利用中の人数が減る', (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await _db();

      await tester.pumpWidget(app(db, _emp('a1', '管理者A', role: EmployeeRole.admin)));
      await tester.pumpAndSettle();

      final row = find.widgetWithText(ListTile, '鈴木');
      await tester.tap(find.descendant(of: row, matching: find.byType(PopupMenuButton<String>)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('無効化する(退職など)'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, '無効化する'));
      await tester.pumpAndSettle();

      expect((await db.doc('companies/c1/employees/m2').get()).data()!['deactivated'], true);
      expect(find.text('利用中 2名 / 上限 5名'), findsOneWidget);
      expect(find.text('無効化されたメンバー(2名)'), findsOneWidget);
    });

    testWidgets('メンバーの権限では画面を使えない', (tester) async {
      final db = await _db();
      await tester.pumpWidget(app(db, _emp('m1', '佐藤')));
      await tester.pumpAndSettle();
      expect(find.text('管理者のみ利用できます'), findsOneWidget);
    });
  });
}
