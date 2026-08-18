import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/churn_risk.dart';

void main() {
  group('ChurnRisk.evaluate', () {
    test('導入から14日未満は判定しない(low)', () {
      final risk = ChurnRisk.evaluate(
        overallCompletionRatePercent: 0,
        daysSinceCompanyCreated: 5,
      );
      expect(risk, ChurnRiskLevel.low);
    });

    test('14日以上経過し受講率20%未満はhigh', () {
      final risk = ChurnRisk.evaluate(
        overallCompletionRatePercent: 10,
        daysSinceCompanyCreated: 30,
      );
      expect(risk, ChurnRiskLevel.high);
    });

    test('14日以上経過し受講率20〜40%未満はmedium', () {
      final risk = ChurnRisk.evaluate(
        overallCompletionRatePercent: 30,
        daysSinceCompanyCreated: 30,
      );
      expect(risk, ChurnRiskLevel.medium);
    });

    test('受講率40%以上はlow', () {
      final risk = ChurnRisk.evaluate(
        overallCompletionRatePercent: 60,
        daysSinceCompanyCreated: 30,
      );
      expect(risk, ChurnRiskLevel.low);
    });
  });
}
