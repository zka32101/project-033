/// チャーン早期検知(設計書 Step3.5 R①): 管理者側の全体受講率が閾値以下→解約予兆アラート。
/// Firestore/UIに依存しない純粋ロジックなのでユニットテストで検証する。
enum ChurnRiskLevel { low, medium, high }

class ChurnRisk {
  /// [overallCompletionRatePercent]はDashboardAnalytics.overallCompletionRatePercentの結果。
  /// [daysSinceCompanyCreated]は導入からの経過日数(導入直後は猶予を与える)。
  static ChurnRiskLevel evaluate({
    required int overallCompletionRatePercent,
    required int daysSinceCompanyCreated,
  }) {
    if (daysSinceCompanyCreated < 14) return ChurnRiskLevel.low; // 導入直後は判定しない
    if (overallCompletionRatePercent < 20) return ChurnRiskLevel.high;
    if (overallCompletionRatePercent < 40) return ChurnRiskLevel.medium;
    return ChurnRiskLevel.low;
  }
}
