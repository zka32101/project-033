import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/streak_calculator.dart';

void main() {
  group('StreakCalculator.currentStreak', () {
    test('活動記録がなければ0', () {
      expect(StreakCalculator.currentStreak([]), 0);
    });

    test('3日連続の活動は3', () {
      final dates = [
        DateTime(2026, 1, 3),
        DateTime(2026, 1, 2),
        DateTime(2026, 1, 1),
      ];
      expect(StreakCalculator.currentStreak(dates), 3);
    });

    test('同じ日に複数回活動しても1日としてカウントする', () {
      final dates = [
        DateTime(2026, 1, 3, 9),
        DateTime(2026, 1, 3, 18),
        DateTime(2026, 1, 2, 8),
      ];
      expect(StreakCalculator.currentStreak(dates), 2);
    });

    test('間に空白日があれば直近の連続日数のみカウントする', () {
      final dates = [
        DateTime(2026, 1, 10),
        DateTime(2026, 1, 9),
        DateTime(2026, 1, 5), // ここで途切れる
        DateTime(2026, 1, 4),
      ];
      expect(StreakCalculator.currentStreak(dates), 2);
    });

    test('順不同で渡されても最新日から正しく計算する', () {
      final dates = [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 3),
        DateTime(2026, 1, 2),
      ];
      expect(StreakCalculator.currentStreak(dates), 3);
    });
  });
}
