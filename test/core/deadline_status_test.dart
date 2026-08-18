import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/deadline_status.dart';

void main() {
  group('DeadlineStatusEvaluator.evaluate', () {
    final now = DateTime(2026, 1, 10);

    test('期限未設定はnone', () {
      final status = DeadlineStatusEvaluator.evaluate(
        dueDate: null,
        isCompleted: false,
        now: now,
      );
      expect(status, DeadlineStatus.none);
    });

    test('完了済みなら期限に関わらずok', () {
      final status = DeadlineStatusEvaluator.evaluate(
        dueDate: DateTime(2026, 1, 1), // 過去日でも
        isCompleted: true,
        now: now,
      );
      expect(status, DeadlineStatus.ok);
    });

    test('期限を過ぎていて未完了ならoverdue', () {
      final status = DeadlineStatusEvaluator.evaluate(
        dueDate: DateTime(2026, 1, 9),
        isCompleted: false,
        now: now,
      );
      expect(status, DeadlineStatus.overdue);
    });

    test('リマインド期間内(デフォルト3日以内)ならupcoming', () {
      final status = DeadlineStatusEvaluator.evaluate(
        dueDate: DateTime(2026, 1, 12),
        isCompleted: false,
        now: now,
      );
      expect(status, DeadlineStatus.upcoming);
    });

    test('リマインド期間より先ならok', () {
      final status = DeadlineStatusEvaluator.evaluate(
        dueDate: DateTime(2026, 1, 20),
        isCompleted: false,
        now: now,
      );
      expect(status, DeadlineStatus.ok);
    });

    test('当日期限はupcoming(残り0日)', () {
      final status = DeadlineStatusEvaluator.evaluate(
        dueDate: DateTime(2026, 1, 10),
        isCompleted: false,
        now: now,
      );
      expect(status, DeadlineStatus.upcoming);
    });

    test('reminderWindowDaysを変更すると判定境界も変わる', () {
      final status = DeadlineStatusEvaluator.evaluate(
        dueDate: DateTime(2026, 1, 15),
        isCompleted: false,
        now: now,
        reminderWindowDays: 7,
      );
      expect(status, DeadlineStatus.upcoming);
    });
  });
}
