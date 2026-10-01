import '../data/models/company_model.dart';
import '../data/models/compliance_item.dart';
import '../data/models/employee_model.dart';
import '../data/models/enrollment_model.dart';
import '../data/models/job_role.dart';
import '../data/models/module_model.dart';

/// レポートの1つの表(Excelの1シート/PDFの1節/CSV1ファイル)。
class ReportTable {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  const ReportTable({
    required this.title,
    required this.headers,
    required this.rows,
  });
}

/// 出力形式(Excel/PDF/CSV)に依存しないレポート内容。
class ReportData {
  final String companyName;
  final DateTime generatedAt;

  /// サマリの(項目, 値)。
  final List<MapEntry<String, String>> summary;
  final List<ReportTable> tables;

  const ReportData({
    required this.companyName,
    required this.generatedAt,
    required this.summary,
    required this.tables,
  });
}

/// 会社の履修状況と法令対応チェックリストから、出力用のレポート内容を組み立てる(純粋ロジック)。
class ReportBuilder {
  const ReportBuilder._();

  static String formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _percent(int done, int total) =>
      total == 0 ? '0%' : '${((done / total) * 100).round()}%';

  static ReportData build({
    required Company company,
    required List<Employee> employees,
    required List<Enrollment> enrollments,
    required List<Module> modules,
    required List<ComplianceItem> checklistItems,
    required Map<String, bool> checklistStatuses,
    required DateTime now,
  }) {
    final moduleIds = modules.map((m) => m.id).toSet();
    // 対象モジュールの修了のみを数える(分母と一致させる)。
    final completedByEmployee = <String, Set<String>>{};
    final lastCompletedByEmployee = <String, DateTime>{};
    final startedByModule = <String, Set<String>>{};
    final completedByModule = <String, Set<String>>{};
    for (final e in enrollments) {
      if (!moduleIds.contains(e.moduleId)) continue;
      if (e.status == EnrollmentStatus.completed) {
        completedByEmployee.putIfAbsent(e.employeeId, () => {}).add(e.moduleId);
        completedByModule.putIfAbsent(e.moduleId, () => {}).add(e.employeeId);
        final at = e.completedAt;
        if (at != null) {
          final prev = lastCompletedByEmployee[e.employeeId];
          if (prev == null || at.isAfter(prev)) {
            lastCompletedByEmployee[e.employeeId] = at;
          }
        }
      } else if (e.status == EnrollmentStatus.inProgress) {
        startedByModule.putIfAbsent(e.moduleId, () => {}).add(e.employeeId);
      }
    }

    final employeeIds = employees.map((e) => e.id).toSet();
    final totalModules = modules.length;

    // --- 社員別 ---
    var totalCompleted = 0;
    var fullyDone = 0;
    final employeeRows = <List<String>>[];
    for (final emp in employees) {
      final done = (completedByEmployee[emp.id] ?? const <String>{}).length;
      totalCompleted += done;
      if (totalModules > 0 && done >= totalModules) fullyDone++;
      final last = lastCompletedByEmployee[emp.id];
      employeeRows.add([
        emp.displayName,
        emp.role == EmployeeRole.admin ? '管理者' : 'メンバー',
        JobRole.labelOf(emp.jobRole) ?? '未設定',
        '$done',
        '$totalModules',
        _percent(done, totalModules),
        last == null ? '' : formatDate(last),
      ]);
    }

    // --- モジュール別 ---
    final moduleRows = <List<String>>[];
    for (final m in modules) {
      final done = (completedByModule[m.id] ?? const <String>{})
          .where(employeeIds.contains)
          .length;
      final inProgress = (startedByModule[m.id] ?? const <String>{})
          .where(
            (id) =>
                employeeIds.contains(id) &&
                !(completedByModule[m.id]?.contains(id) ?? false),
          )
          .length;
      final notStarted = employees.length - done - inProgress;
      moduleRows.add([
        m.title,
        '$done',
        '$inProgress',
        '${notStarted < 0 ? 0 : notStarted}',
        _percent(done, employees.length),
      ]);
    }

    // --- 法令対応チェックリスト ---
    final headcount = company.contractedHeadcount;
    var mandatoryApplicable = 0;
    var mandatoryDone = 0;
    final checklistRows = <List<String>>[];
    for (final item in checklistItems) {
      final applies = item.appliesTo(headcount);
      final done = checklistStatuses[item.id] ?? false;
      if (applies && item.isMandatory) {
        mandatoryApplicable++;
        if (done) mandatoryDone++;
      }
      checklistRows.add([
        item.category.label,
        item.title,
        item.law,
        item.isMandatory ? '義務' : '推奨',
        applies ? '対象' : '対象外(${item.minHeadcount}名以上)',
        !applies ? '-' : (done ? '実施済み' : '未実施'),
      ]);
    }

    final denominator = employees.length * totalModules;
    return ReportData(
      companyName: company.name,
      generatedAt: now,
      summary: [
        MapEntry('会社名', company.name),
        MapEntry('出力日', formatDate(now)),
        MapEntry('対象社員数', '${employees.length}名'),
        MapEntry('対象モジュール数', '$totalModules件'),
        MapEntry('全体の受講率', _percent(totalCompleted, denominator)),
        MapEntry('全モジュール修了者', '$fullyDone名'),
        MapEntry('未修了者', '${employees.length - fullyDone}名'),
        MapEntry(
          '法令対応(義務項目)の実施率',
          '${_percent(mandatoryDone, mandatoryApplicable)}($mandatoryDone/$mandatoryApplicable項目)',
        ),
      ],
      tables: [
        ReportTable(
          title: '社員別の受講状況',
          headers: const ['氏名', '役割', '職種', '修了数', '対象数', '受講率', '最終修了日'],
          rows: employeeRows,
        ),
        ReportTable(
          title: 'モジュール別の受講状況',
          headers: const ['モジュール', '修了', '受講中', '未着手', '修了率'],
          rows: moduleRows,
        ),
        ReportTable(
          title: '法令対応チェックリスト',
          headers: const ['分類', '項目', '根拠法令', '区分', '適用', '状況'],
          rows: checklistRows,
        ),
      ],
    );
  }
}
