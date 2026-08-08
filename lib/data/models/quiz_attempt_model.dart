import 'firestore_date_parser.dart';

class QuizAttempt {
  final String id;
  final String employeeId;
  final String moduleId;
  final int score; // 正答率(%)
  final bool passed;
  final int thresholdApplied; // 合格時点で適用されていた合格ライン
  final List<int> selectedAnswers;
  final DateTime answeredAt;

  const QuizAttempt({
    required this.id,
    required this.employeeId,
    required this.moduleId,
    required this.score,
    required this.passed,
    required this.thresholdApplied,
    required this.selectedAnswers,
    required this.answeredAt,
  });

  factory QuizAttempt.evaluate({
    required String id,
    required String employeeId,
    required String moduleId,
    required List<int> selectedAnswers,
    required List<int> correctIndexes,
    required int thresholdApplied,
    required DateTime answeredAt,
  }) {
    final correctCount = List.generate(
      correctIndexes.length,
      (i) => (i < selectedAnswers.length && selectedAnswers[i] == correctIndexes[i]) ? 1 : 0,
    ).fold<int>(0, (a, b) => a + b);
    final score = correctIndexes.isEmpty
        ? 0
        : ((correctCount / correctIndexes.length) * 100).round();
    return QuizAttempt(
      id: id,
      employeeId: employeeId,
      moduleId: moduleId,
      score: score,
      passed: score >= thresholdApplied,
      thresholdApplied: thresholdApplied,
      selectedAnswers: selectedAnswers,
      answeredAt: answeredAt,
    );
  }

  factory QuizAttempt.fromMap(String id, Map<String, dynamic> map) {
    return QuizAttempt(
      id: id,
      employeeId: map['employeeId'] as String? ?? '',
      moduleId: map['moduleId'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      passed: map['passed'] as bool? ?? false,
      thresholdApplied: (map['thresholdApplied'] as num?)?.toInt() ?? 80,
      selectedAnswers:
          List<int>.from((map['selectedAnswers'] as List?) ?? []),
      answeredAt: parseFirestoreDateTime(map['answeredAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'employeeId': employeeId,
        'moduleId': moduleId,
        'score': score,
        'passed': passed,
        'thresholdApplied': thresholdApplied,
        'selectedAnswers': selectedAnswers,
        'answeredAt': answeredAt,
      };
}
