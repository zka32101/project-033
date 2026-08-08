import 'growth_analytics.dart';

/// 誤答傾向分析→復習提案(設計書 Should機能)。
/// マイ成長画面のカテゴリスコアから、正答率が低い(=誤答が多い)カテゴリを優先して復習提案する。
class ReviewRecommender {
  /// 受験履歴があるカテゴリのうち、正答率が低い順に並べて返す(復習優先度の高い順)。
  /// 受験履歴が無いカテゴリ(attemptCount == 0)は未着手であり「復習」対象ではないため除外する。
  static List<CategoryScore> recommendForReview(
    List<CategoryScore> scores, {
    int scoreThreshold = 80,
  }) {
    final candidates = scores
        .where((s) => s.attemptCount > 0 && s.averageScore < scoreThreshold)
        .toList()
      ..sort((a, b) => a.averageScore.compareTo(b.averageScore));
    return candidates;
  }
}
