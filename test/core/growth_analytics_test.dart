import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/growth_analytics.dart';
import 'package:safy/data/models/quiz_attempt_model.dart';
import 'package:safy/data/models/category_model.dart';

QuizAttempt _attempt(String moduleId, int score, DateTime at) {
  return QuizAttempt(
    id: 'a-$moduleId-$score',
    employeeId: 'e1',
    moduleId: moduleId,
    score: score,
    passed: score >= 80,
    thresholdApplied: 80,
    selectedAnswers: const [],
    answeredAt: at,
  );
}

void main() {
  group('GrowthAnalytics.computeRadarScores', () {
    test('カテゴリごとの平均正答率を算出する', () {
      final attempts = [
        _attempt('m-security-1', 80, DateTime(2026, 1, 1)),
        _attempt('m-security-2', 100, DateTime(2026, 1, 2)),
        _attempt('m-privacy-1', 60, DateTime(2026, 1, 3)),
      ];
      final map = {
        'm-security-1': CategoryId.security,
        'm-security-2': CategoryId.security,
        'm-privacy-1': CategoryId.privacy,
      };

      final result = GrowthAnalytics.computeRadarScores(
        attempts: attempts,
        moduleCategoryMap: map,
      );

      final security =
          result.firstWhere((r) => r.categoryId == CategoryId.security);
      final privacy =
          result.firstWhere((r) => r.categoryId == CategoryId.privacy);
      final aiUsage =
          result.firstWhere((r) => r.categoryId == CategoryId.aiUsage);

      expect(security.averageScore, 90);
      expect(security.attemptCount, 2);
      expect(privacy.averageScore, 60);
      expect(aiUsage.averageScore, 0); // 受験履歴なしカテゴリは0
      expect(aiUsage.attemptCount, 0);
      expect(result.length, Category.all.length); // 全6カテゴリが必ず含まれる
    });
  });

  group('GrowthAnalytics.compareFirstVsLatest', () {
    test('最初と最新の受験を比較し成長幅を返す', () {
      final attempts = [
        _attempt('m1', 60, DateTime(2026, 1, 1)),
        _attempt('m1', 70, DateTime(2026, 1, 5)),
        _attempt('m1', 90, DateTime(2026, 1, 10)),
      ];
      final result = GrowthAnalytics.compareFirstVsLatest(attempts);
      expect(result, isNotNull);
      expect(result!.firstScore, 60);
      expect(result.latestScore, 90);
      expect(result.improvement, 30);
    });

    test('受験履歴が空の場合はnullを返す', () {
      expect(GrowthAnalytics.compareFirstVsLatest([]), isNull);
    });
  });
}
