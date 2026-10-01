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
    // 社員ごとの受講対象(必須)の研修ID。nullを返す/未指定なら、全研修(totalModuleCount件)が対象。
    // 会社全体・所属チームの指定に応じて、社員ごとに分母と数える修了が変わる。
    Set<String>? Function(Employee employee)? moduleIdsFor,
  }) {
    return employees.map((employee) {
      final ids = moduleIdsFor?.call(employee);
      final completed = enrollments
          .where((e) =>
              e.employeeId == employee.id &&
              e.status == EnrollmentStatus.completed &&
              (ids == null || ids.contains(e.moduleId)))
          .length;
      return EmployeeCompletionStat(
        employeeId: employee.id,
        displayName: employee.displayName,
        completedCount: completed,
        totalModuleCount: ids?.length ?? totalModuleCount,
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
    Set<String>? Function(Employee employee)? moduleIdsFor,
  }) {
    final byTeam = <String, List<Employee>>{};
    for (final employee in employees) {
      byTeam.putIfAbsent(employee.teamId, () => []).add(employee);
    }
    return byTeam.entries.map((entry) {
      final teamEmployees = entry.value;
      var completed = 0;
      var possible = 0;
      for (final employee in teamEmployees) {
        final ids = moduleIdsFor?.call(employee);
        possible += ids?.length ?? totalModuleCount;
        completed += enrollments
            .where((e) =>
                e.employeeId == employee.id &&
                e.status == EnrollmentStatus.completed &&
                (ids == null || ids.contains(e.moduleId)))
            .length;
      }
      return TeamCompletionStat(
        teamId: entry.key,
        employeeCount: teamEmployees.length,
        completedCount: completed,
        totalPossibleCount: possible,
      );
    }).toList()
      ..sort((a, b) => b.completionRatePercent.compareTo(a.completionRatePercent));
  }
}
