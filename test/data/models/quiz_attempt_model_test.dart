import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/quiz_attempt_model.dart';

void main() {
  group('QuizAttempt.evaluate', () {
    test('全問正解は合格・スコア100', () {
      final attempt = QuizAttempt.evaluate(
        id: 'a1',
        employeeId: 'e1',
        moduleId: 'm1',
        selectedAnswers: [0, 1, 2],
        correctIndexes: [0, 1, 2],
        thresholdApplied: 80,
        answeredAt: DateTime(2026, 1, 1),
      );
      expect(attempt.score, 100);
      expect(attempt.passed, isTrue);
    });

    test('閾値未満は不合格', () {
      final attempt = QuizAttempt.evaluate(
        id: 'a2',
        employeeId: 'e1',
        moduleId: 'm1',
        selectedAnswers: [0, 0, 0],
        correctIndexes: [0, 1, 2],
        thresholdApplied: 80,
        answeredAt: DateTime(2026, 1, 1),
      );
      expect(attempt.score, closeTo(33, 1));
      expect(attempt.passed, isFalse);
    });

    test('ちょうど閾値と同じスコアは合格', () {
      final attempt = QuizAttempt.evaluate(
        id: 'a3',
        employeeId: 'e1',
        moduleId: 'm1',
        selectedAnswers: [0, 1, 2, 0],
        correctIndexes: [0, 1, 2, 1],
        thresholdApplied: 75,
        answeredAt: DateTime(2026, 1, 1),
      );
      expect(attempt.score, 75);
      expect(attempt.passed, isTrue);
    });

    test('thresholdAppliedが記録され後日の基準変更の影響を受けない', () {
      final attempt = QuizAttempt.evaluate(
        id: 'a4',
        employeeId: 'e1',
        moduleId: 'm1',
        selectedAnswers: [0],
        correctIndexes: [0],
        thresholdApplied: 70,
        answeredAt: DateTime(2026, 1, 1),
      );
      expect(attempt.thresholdApplied, 70);
    });
  });
}
