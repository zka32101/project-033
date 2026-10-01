import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/dashboard_analytics.dart';
import 'package:safy/core/editor_stamp.dart';
import 'package:safy/services/company_service.dart';
import 'package:safy/services/invite_service.dart';
import 'package:safy/core/report_data.dart';
import 'package:safy/core/required_modules.dart';
import 'package:safy/data/models/category_model.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/data/models/enrollment_model.dart';
import 'package:safy/data/models/module_model.dart';
import 'package:safy/data/models/team_model.dart';
import 'package:safy/features/admin/team_management/team_assignment_screen.dart';
import 'package:safy/providers/firebase_providers.dart';
import 'package:safy/providers/session_provider.dart';
import 'package:safy/providers/team_assignment_provider.dart';

Employee _emp(
  String id,
  String team, {
  EmployeeRole role = EmployeeRole.member,
}) => Employee(
  id: id,
  companyId: 'c1',
  teamId: team,
  displayName: id,
  role: role,
  createdAt: DateTime(2026, 1, 1),
);

Enrollment _done(String emp, String module) => Enrollment(
  id: '$emp-$module',
  employeeId: emp,
  moduleId: module,
  status: EnrollmentStatus.completed,
  completedAt: DateTime(2026, 9, 1),
);

Module _mod(String id, String title, {CategoryId c = CategoryId.security}) =>
    Module(
      id: id,
      categoryId: c,
      title: title,
      description: '',
      passThresholdDefault: 80,
      isFreeTrial: false,
      sortOrder: 1,
    );

Company _company({List<String>? assigned}) => Company(
  id: 'c1',
  name: 'テスト',
  industryId: 'retail',
  planType: PlanType.trial,
  contractedHeadcount: 5,
  customPassThreshold: const {},
  createdAt: DateTime(2026, 1, 1),
  assignedModuleIds: assigned,
);

class _Session extends SessionNotifier {
  _Session(Employee employee, Company company) {
    state = SessionState(employee: employee, company: company);
  }
}

void main() {
  stampTests();
  group('RequiredModules', () {
    test('会社が指定していなければ、社員の受講対象は全研修(null)', () {
      expect(
        RequiredModules.forEmployee(companyAssigned: null, teamExtra: ['m9']),
        isNull,
      );
    });

    test('必須 = 全社共通 + チームの追加', () {
      expect(
        RequiredModules.forEmployee(
          companyAssigned: ['m1', 'm2'],
          teamExtra: ['m2', 'm3'],
        ),
        {'m1', 'm2', 'm3'},
      );
      expect(RequiredModules.forEmployee(companyAssigned: ['m1']), {'m1'});
    });

    test('ホームの必須表示: チームの追加は常に必須、会社指定があればそれ、なければ重点分野', () {
      bool r(
        String id, {
        List<String>? company,
        List<String> team = const [],
        bool high = false,
      }) => RequiredModules.isRequired(
        moduleId: id,
        companyAssigned: company,
        teamExtra: team,
        categoryHigh: high,
      );
      expect(r('m1', company: ['m1']), isTrue);
      expect(r('m2', company: ['m1']), isFalse);
      expect(r('m2', company: ['m1'], team: ['m2']), isTrue);
      expect(r('m3', company: ['m1'], high: true), isFalse); // 会社指定があれば重点分野は無関係
      expect(r('m3', company: null, high: true), isTrue);
      expect(r('m3', company: null, high: false), isFalse);
      expect(r('m3', company: null, team: ['m3']), isTrue);
    });
  });

  group('受講率: 社員ごとの必須で集計', () {
    final sales = _emp('s1', 'sales');
    final acct = _emp('a1', 'acct');
    final enrollments = [
      _done('s1', 'm1'),
      _done('s1', 'm2'),
      _done('a1', 'm1'),
    ];
    Set<String>? forEmp(Employee e) => RequiredModules.forEmployee(
      companyAssigned: ['m1'],
      teamExtra: e.teamId == 'sales' ? ['m2'] : const [],
    );

    test('営業チームは(全社+追加)2件、経理は全社1件が分母になる', () {
      final stats = DashboardAnalytics.computeEmployeeCompletionStats(
        employees: [sales, acct],
        enrollments: enrollments,
        totalModuleCount: 99,
        moduleIdsFor: forEmp,
      );
      expect(stats[0].totalModuleCount, 2);
      expect(stats[0].completedCount, 2);
      expect(stats[1].totalModuleCount, 1);
      expect(stats[1].completedCount, 1);
      expect(stats.every((s) => s.completionRatePercent == 100), isTrue);
    });

    test('チーム比較も社員ごとの必須で集計される', () {
      final stats = DashboardAnalytics.computeTeamCompletionStats(
        employees: [sales, acct],
        enrollments: [_done('s1', 'm1'), _done('a1', 'm1')],
        totalModuleCount: 99,
        moduleIdsFor: forEmp,
      );
      final salesStat = stats.firstWhere((s) => s.teamId == 'sales');
      final acctStat = stats.firstWhere((s) => s.teamId == 'acct');
      expect(salesStat.completionRatePercent, 50); // 1/2
      expect(acctStat.completionRatePercent, 100); // 1/1
    });
  });

  group('レポート: チームごとの必須', () {
    test('社員別・モジュール別・サマリがチームの必須で計算される', () {
      final data = ReportBuilder.build(
        company: _company(assigned: ['m1']),
        employees: [_emp('s1', 'sales'), _emp('a1', 'acct')],
        enrollments: [_done('s1', 'm1'), _done('a1', 'm1')],
        modules: [
          _mod('m1', '全社の研修'),
          _mod('m2', '営業だけの研修'),
          _mod('m3', '誰も必須でない研修'),
        ],
        checklistItems: const [],
        checklistStatuses: const {},
        now: DateTime(2026, 10, 1),
        requiredFor: (e) => RequiredModules.forEmployee(
          companyAssigned: ['m1'],
          teamExtra: e.teamId == 'sales' ? ['m2'] : const [],
        ),
      );
      final summary = {for (final e in data.summary) e.key: e.value};
      expect(summary['対象モジュール数'], '2件'); // m3は誰も必須でないので載らない
      expect(summary['全体の受講率'], '67%'); // 2/(2+1)
      expect(summary['全モジュール修了者'], '1名'); // 経理のみ

      final employees = data.tables[0].rows;
      expect(employees[0].sublist(3, 6), ['1', '2', '50%']); // 営業 s1
      expect(employees[1].sublist(3, 6), ['1', '1', '100%']); // 経理 a1

      final modules = data.tables[1].rows;
      expect(modules.map((r) => r[0]), ['全社の研修', '営業だけの研修']);
      expect(modules[0].sublist(1), ['2', '0', '0', '100%']); // 2人とも必須・修了
      expect(modules[1].sublist(1), ['0', '0', '1', '0%']); // 営業1人だけが必須・未着手
    });
  });

  group('Team', () {
    test('追加の必須研修は保存・復元でき、未指定なら空', () {
      final t = Team(
        id: 't',
        companyId: 'c1',
        teamName: '営業',
        createdAt: DateTime(2026, 1, 1),
        assignedModuleIds: const ['m1', 'm2'],
      );
      expect(Team.fromMap('t', t.toMap()).assignedModuleIds, ['m1', 'm2']);
      expect(Team.fromMap('t', {'teamName': 'x'}).assignedModuleIds, isEmpty);
    });
  });

  group('myTeamExtraModulesProvider(社員ホーム用)', () {
    test('自分のチームの追加の必須を返し、未所属・未指定は空', () async {
      final db = FakeFirebaseFirestore();
      await db.doc('companies/c1/teams/sales').set({
        'teamName': '営業',
        'assignedModuleIds': ['m2'],
      });
      await db.doc('companies/c1/teams/acct').set({'teamName': '経理'});

      Future<List<String>> read(String teamId) async {
        final container = ProviderContainer(
          overrides: [
            firestoreProvider.overrideWithValue(db),
            sessionProvider.overrideWith(
              (ref) => _Session(_emp('e', teamId), _company()),
            ),
          ],
        );
        addTearDown(container.dispose);
        return container.read(myTeamExtraModulesProvider.future);
      }

      expect(await read('sales'), ['m2']);
      expect(await read('acct'), isEmpty);
      expect(await read(''), isEmpty);
    });
  });

  group('TeamModuleAssignmentScreen', () {
    Future<FakeFirebaseFirestore> seeded() async {
      final db = FakeFirebaseFirestore();
      await db.doc('companies/c1/teams/sales').set({
        'companyId': 'c1',
        'teamName': '営業',
        'createdAt': DateTime(2026, 1, 1),
      });
      await db.doc('industries/retail').set({
        'name': '小売',
        'highPriority': ['security'],
        'midPriority': <String>[],
        'lowPriority': ['compliance'],
      });
      for (final m in [
        ('m1', '全社共通の研修', 'security'),
        ('m2', '営業だけの研修', 'compliance'),
        ('m3', 'その他の研修', 'compliance'),
      ]) {
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

    testWidgets('全社共通の必須は外せず、追加の研修を選んで保存すると、チームに保存される', (tester) async {
      tester.view.physicalSize = const Size(900, 2800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await seeded();
      final team = Team(
        id: 'sales',
        companyId: 'c1',
        teamName: '営業',
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(db),
            sessionProvider.overrideWith(
              (ref) => _Session(
                _emp('admin', 'sales', role: EmployeeRole.admin),
                _company(assigned: ['m1']),
              ),
            ),
          ],
          child: MaterialApp(home: TeamModuleAssignmentScreen(team: team)),
        ),
      );
      await tester.pumpAndSettle();

      CheckboxListTile tile(String title) => tester.widget(
        find.widgetWithText(CheckboxListTile, title, skipOffstage: false),
      );
      expect(tile('全社共通の研修').value, isTrue);
      expect(tile('全社共通の研修').onChanged, isNull); // 外せない
      expect(find.text('全社共通の必須'), findsOneWidget);
      expect(tile('営業だけの研修').value, isFalse);

      await tester.tap(find.widgetWithText(CheckboxListTile, '営業だけの研修'));
      await tester.pump();
      expect(find.text('このチームの追加: 1件'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'この内容で保存する'));
      await tester.pumpAndSettle();

      final saved =
          (await db.doc('companies/c1/teams/sales').get())
                  .data()!['assignedModuleIds']
              as List;
      expect(saved, ['m2']); // 全社共通(m1)は含めない
    });
  });
}

void stampTests() {
  group('設定の書き込みに操作者のスタンプが付く', () {
    test('会社設定・チームの追加の必須・招待コード発行に lastEditedBy が付く', () async {
      final db = FakeFirebaseFirestore();
      await db.doc('companies/c1').set({'name': 'テスト'});
      await db.doc('companies/c1/teams/sales').set({'teamName': '営業'});
      EditorStamp.uidProvider = () => 'admin1';
      addTearDown(() => EditorStamp.uidProvider = () => null);

      final service = CompanyService(db);
      await service.updateAssignedModules(companyId: 'c1', moduleIds: ['m1']);
      await service.updateModulePassThreshold(
        companyId: 'c1',
        moduleId: 'm1',
        threshold: 90,
      );
      await service.updateTeamAssignedModules(
        companyId: 'c1',
        teamId: 'sales',
        moduleIds: ['m2'],
      );

      expect(
        (await db.doc('companies/c1').get()).data()!['lastEditedBy'],
        'admin1',
      );
      expect(
        (await db.doc('companies/c1/teams/sales').get())
            .data()!['lastEditedBy'],
        'admin1',
      );

      final team = await InviteService(
        db,
      ).createTeam(companyId: 'c1', teamName: '経理');
      expect(
        (await db.doc('companies/c1/teams/${team.id}').get())
            .data()!['lastEditedBy'],
        'admin1',
      );
    });
  });
}
