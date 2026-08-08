/// 連続受講日数(ストリーク)の算出。設計書 Step5.5: ゲーム性(軽め)のストリーク表示に使用。
/// Firestore/UIに依存しない純粋ロジックなのでユニットテストで検証する。
class StreakCalculator {
  /// [activityDates]は受講活動(レッスン閲覧・クイズ合格など)のタイムスタンプ一覧。
  /// 直近の活動日から連続している日数を返す(同日複数回は1日としてカウント)。
  static int currentStreak(List<DateTime> activityDates) {
    if (activityDates.isEmpty) return 0;

    final uniqueDays = activityDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // 新しい順

    var streak = 1;
    for (var i = 0; i < uniqueDays.length - 1; i++) {
      final diff = uniqueDays[i].difference(uniqueDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
