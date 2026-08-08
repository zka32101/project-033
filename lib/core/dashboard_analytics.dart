import '../data/models/employee_model.dart';
import '../data/models/enrollment_model.dart';

/// 管理者ダッシュボード(チーム別・個人別履修状況)の集計ロジック。
/// Firestore/UIに依存しない純粋ロジックなのでユニットテストで検証する。
class EmployeeCompletionStat {
  final String employeeId;
  final String displayName;
  final int completedCount;
  final int totalModuleCount;

  const EmployeeCompletionStat({
    required this.employeeId,
    required this.displayName,
    required this.completedCount,
    required this.totalModuleCount,
  });

  int get completionRatePercent =>
      totalModuleCount == 0 ? 0 : ((completedCount / totalModuleCount) * 100).round();
}

class TeamCompletionStat {
  final String teamId;
  final int employeeCount;
  final int completedCount;
  final int totalPossibleCount;

  const TeamCompletionStat({
    required this.teamId,
    required this.employeeCount,
    required this.completedCount,
    required this.totalPossibleCount,
  });

  int get completionRatePercent =>
      totalPossibleCount == 0 ? 0 : ((completedCount / totalPossibleCount) * 100).round();
}

class DashboardAnalytics {
  static List<EmployeeCompletionStat> computeEmployeeCompletionStats({
    required List<Employee> employees,
    required List<Enrollment> enrollments,
    required int totalModuleCount,
  }) {
    return employees.map((employee) {
      final completed = enrollments
          .where((e) =>
              e.employeeId == employee.id &&
              e.status == EnrollmentStatus.completed)
          .length;
      return EmployeeCompletionStat(
        employeeId: employee.id,
        displayName: employee.displayName,
        completedCount: completed,
        totalModuleCount: totalModuleCount,
      );
    }).toList();
  }

  /// 会社全体の受講率(管理者の週次チェック・チャーン早期検知に使用)
  static int overallCompletionRatePercent(List<EmployeeCompletionStat> stats) {
    if (stats.isEmpty) return 0;
    final total = stats.fold<int>(0, (sum, s) => sum + s.completionRatePercent);
    return (total / stats.length).round();
  }

  /// チーム単位の受講率比較(teamId未設定の社員は"" のチームにまとめる)
  static List<TeamCompletionStat> computeTeamCompletionStats({
    required List<Employee> employees,
    required List<Enrollment> enrollments,
    required int totalModuleCount,
  }) {
    final byTeam = <String, List<Employee>>{};
    for (final employee in employees) {
      byTeam.putIfAbsent(employee.teamId, () => []).add(employee);
    }
    return byTeam.entries.map((entry) {
      final teamEmployees = entry.value;
      final completed = teamEmployees.fold<int>(
        0,
        (sum, employee) => sum +
            enrollments
                .where((e) =>
                    e.employeeId == employee.id &&
                    e.status == EnrollmentStatus.completed)
                .length,
      );
      return TeamCompletionStat(
        teamId: entry.key,
        employeeCount: teamEmployees.length,
        completedCount: completed,
        totalPossibleCount: teamEmployees.length * totalModuleCount,
      );
    }).toList()
      ..sort((a, b) => b.completionRatePercent.compareTo(a.completionRatePercent));
  }
}
