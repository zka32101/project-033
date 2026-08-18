import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/dashboard_analytics.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/data/models/enrollment_model.dart';

Employee _employee(String id, String name) {
  return Employee(
    id: id,
    companyId: 'c1',
    teamId: 't1',
    displayName: name,
    role: EmployeeRole.member,
    createdAt: DateTime(2026, 1, 1),
  );
}

Enrollment _completed(String employeeId, String moduleId) {
  return Enrollment(
    id: 'e-$employeeId-$moduleId',
    employeeId: employeeId,
    moduleId: moduleId,
    status: EnrollmentStatus.completed,
  );
}

void main() {
  group('DashboardAnalytics.computeEmployeeCompletionStats', () {
    test('完了モジュール数に基づき受講率を算出する', () {
      final employees = [_employee('e1', '山田'), _employee('e2', '佐藤')];
      final enrollments = [
        _completed('e1', 'm1'),
        _completed('e1', 'm2'),
        _completed('e2', 'm1'),
      ];

      final stats = DashboardAnalytics.computeEmployeeCompletionStats(
        employees: employees,
        enrollments: enrollments,
        totalModuleCount: 4,
      );

      final yamada = stats.firstWhere((s) => s.employeeId == 'e1');
      final sato = stats.firstWhere((s) => s.employeeId == 'e2');

      expect(yamada.completedCount, 2);
      expect(yamada.completionRatePercent, 50);
      expect(sato.completedCount, 1);
      expect(sato.completionRatePercent, 25);
    });

    test('対象モジュール数が0の場合は受講率0を返す(ゼロ除算を防ぐ)', () {
      final stats = DashboardAnalytics.computeEmployeeCompletionStats(
        employees: [_employee('e1', '山田')],
        enrollments: [],
        totalModuleCount: 0,
      );
      expect(stats.first.completionRatePercent, 0);
    });
  });

  group('DashboardAnalytics.overallCompletionRatePercent', () {
    test('全社員の受講率の平均を返す', () {
      final stats = DashboardAnalytics.computeEmployeeCompletionStats(
        employees: [_employee('e1', '山田'), _employee('e2', '佐藤')],
        enrollments: [_completed('e1', 'm1'), _completed('e1', 'm2')],
        totalModuleCount: 2,
      );
      // 山田: 100%, 佐藤: 0% -> 平均50%
      expect(DashboardAnalytics.overallCompletionRatePercent(stats), 50);
    });

    test('社員がいない場合は0を返す', () {
      expect(DashboardAnalytics.overallCompletionRatePercent([]), 0);
    });
  });

  group('DashboardAnalytics.computeTeamCompletionStats', () {
    Employee employeeInTeam(String id, String teamId) {
      return Employee(
        id: id,
        companyId: 'c1',
        teamId: teamId,
        displayName: id,
        role: EmployeeRole.member,
        createdAt: DateTime(2026, 1, 1),
      );
    }

    test('チームごとに受講率を集計する', () {
      final employees = [
        employeeInTeam('e1', 'teamA'),
        employeeInTeam('e2', 'teamA'),
        employeeInTeam('e3', 'teamB'),
      ];
      final enrollments = [
        _completed('e1', 'm1'),
        _completed('e1', 'm2'),
        _completed('e3', 'm1'),
      ];

      final stats = DashboardAnalytics.computeTeamCompletionStats(
        employees: employees,
        enrollments: enrollments,
        totalModuleCount: 2,
      );

      final teamA = stats.firstWhere((s) => s.teamId == 'teamA');
      final teamB = stats.firstWhere((s) => s.teamId == 'teamB');

      expect(teamA.employeeCount, 2);
      expect(teamA.completedCount, 2);
      expect(teamA.completionRatePercent, 50); // 2 / (2人×2モジュール=4)
      expect(teamB.employeeCount, 1);
      expect(teamB.completionRatePercent, 50); // 1 / (1人×2モジュール=2)
    });

    test('受講率が高いチーム順にソートされる', () {
      final employees = [employeeInTeam('e1', 'low'), employeeInTeam('e2', 'high')];
      final enrollments = [_completed('e2', 'm1')];

      final stats = DashboardAnalytics.computeTeamCompletionStats(
        employees: employees,
        enrollments: enrollments,
        totalModuleCount: 1,
      );

      expect(stats.first.teamId, 'high');
      expect(stats.last.teamId, 'low');
    });

    test('teamId未設定の社員は空文字のチームにまとめられる', () {
      final employees = [employeeInTeam('e1', '')];
      final stats = DashboardAnalytics.computeTeamCompletionStats(
        employees: employees,
        enrollments: [],
        totalModuleCount: 3,
      );
      expect(stats.single.teamId, '');
      expect(stats.single.employeeCount, 1);
    });
  });
}
