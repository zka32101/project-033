import '../data/models/module_model.dart';
import '../data/models/enrollment_model.dart';
import '../data/models/quiz_attempt_model.dart';

/// 管理者側「受講状況・点数」詳細画面用の集計ロジック。
/// Firestore/UIに依存しない純粋ロジックなのでユニットテストで検証する。
class EmployeeModuleProgress {
  final Module module;
  final EnrollmentStatus status;
  final int? latestScore; // そのモジュールの最新クイズスコア(未受験ならnull)
  final bool? latestPassed;
  final int attemptCount;

  const EmployeeModuleProgress({
    required this.module,
    required this.status,
    required this.latestScore,
    required this.latestPassed,
    required this.attemptCount,
  });
}

class EmployeeModuleProgressBuilder {
  /// [attempts]は古い順に並んでいる想定(QuizAttempt.answeredAt昇順)。
  static List<EmployeeModuleProgress> build({
    required List<Module> modules,
    required List<Enrollment> enrollments,
    required List<QuizAttempt> attempts,
  }) {
    return modules.map((module) {
      final enrollment = enrollments.where((e) => e.moduleId == module.id).firstOrNull;
      final moduleAttempts = attempts.where((a) => a.moduleId == module.id).toList();
      final latest = moduleAttempts.isEmpty ? null : moduleAttempts.last;

      return EmployeeModuleProgress(
        module: module,
        status: enrollment?.status ?? EnrollmentStatus.notStarted,
        latestScore: latest?.score,
        latestPassed: latest?.passed,
        attemptCount: moduleAttempts.length,
      );
    }).toList();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
