import '../data/models/quiz_attempt_model.dart';
import '../data/models/category_model.dart';

/// マイ成長画面（レーダーチャート・Before-After比較）の集計ロジック。
/// Firestore/UIに依存しない純粋ロジックなのでユニットテストで検証する。
class CategoryScore {
  final CategoryId categoryId;
  final int averageScore; // 0-100
  final int attemptCount;

  const CategoryScore({
    required this.categoryId,
    required this.averageScore,
    required this.attemptCount,
  });
}

class BeforeAfterComparison {
  final int firstScore;
  final int latestScore;
  final int improvement; // latestScore - firstScore (負の場合もあり得る)

  const BeforeAfterComparison({
    required this.firstScore,
    required this.latestScore,
    required this.improvement,
  });
}

class GrowthAnalytics {
  /// カテゴリごとの平均正答率をレーダーチャート用に集計する。
  /// [moduleCategoryMap] は moduleId -> CategoryId のマッピング。
  static List<CategoryScore> computeRadarScores({
    required List<QuizAttempt> attempts,
    required Map<String, CategoryId> moduleCategoryMap,
  }) {
    final scoresByCategory = <CategoryId, List<int>>{};
    for (final attempt in attempts) {
      final categoryId = moduleCategoryMap[attempt.moduleId];
      if (categoryId == null) continue;
      scoresByCategory.putIfAbsent(categoryId, () => []).add(attempt.score);
    }

    return Category.all.map((category) {
      final scores = scoresByCategory[category.id] ?? const <int>[];
      final average = scores.isEmpty
          ? 0
          : (scores.reduce((a, b) => a + b) / scores.length).round();
      return CategoryScore(
        categoryId: category.id,
        averageScore: average,
        attemptCount: scores.length,
      );
    }).toList();
  }

  /// 同一モジュールの最初の受験と最新の受験を比較する(成長実感の可視化)。
  /// 受験履歴は[attemptsForModule]に古い順で渡すこと。
  static BeforeAfterComparison? compareFirstVsLatest(
      List<QuizAttempt> attemptsForModule) {
    if (attemptsForModule.isEmpty) return null;
    final first = attemptsForModule.first.score;
    final latest = attemptsForModule.last.score;
    return BeforeAfterComparison(
      firstScore: first,
      latestScore: latest,
      improvement: latest - first,
    );
  }
}
