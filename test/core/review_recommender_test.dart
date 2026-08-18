import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/review_recommender.dart';
import 'package:safy/core/growth_analytics.dart';
import 'package:safy/data/models/category_model.dart';

void main() {
  group('ReviewRecommender.recommendForReview', () {
    test('正答率が閾値未満のカテゴリを低い順に返す', () {
      final scores = [
        const CategoryScore(
            categoryId: CategoryId.security, averageScore: 90, attemptCount: 2),
        const CategoryScore(
            categoryId: CategoryId.privacy, averageScore: 60, attemptCount: 1),
        const CategoryScore(
            categoryId: CategoryId.compliance, averageScore: 75, attemptCount: 3),
      ];

      final result = ReviewRecommender.recommendForReview(scores);

      expect(result.length, 2);
      expect(result[0].categoryId, CategoryId.privacy); // 60点が最優先
      expect(result[1].categoryId, CategoryId.compliance);
    });

    test('受験履歴のないカテゴリ(未着手)は復習対象から除外する', () {
      final scores = [
        const CategoryScore(
            categoryId: CategoryId.aiUsage, averageScore: 0, attemptCount: 0),
      ];
      expect(ReviewRecommender.recommendForReview(scores), isEmpty);
    });

    test('閾値以上のカテゴリのみなら空リストを返す', () {
      final scores = [
        const CategoryScore(
            categoryId: CategoryId.security, averageScore: 95, attemptCount: 2),
      ];
      expect(ReviewRecommender.recommendForReview(scores), isEmpty);
    });
  });
}
