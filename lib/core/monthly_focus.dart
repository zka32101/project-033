import '../data/models/module_model.dart';
import '../data/models/enrollment_model.dart';

/// 月次「今月の必須モジュール」(設計書 Step3.5 R①: 継続動線)。
/// 業種優先度順のモジュール一覧から、未受講(または未完了)の最優先モジュールを1つ選ぶ。
class MonthlyFocus {
  static Module? pick({
    required List<Module> priorityOrderedModules,
    required List<Enrollment> employeeEnrollments,
  }) {
    final completedModuleIds = employeeEnrollments
        .where((e) => e.status == EnrollmentStatus.completed)
        .map((e) => e.moduleId)
        .toSet();

    for (final module in priorityOrderedModules) {
      if (!completedModuleIds.contains(module.id)) {
        return module;
      }
    }
    return null; // 全モジュール完了済み
  }
}
