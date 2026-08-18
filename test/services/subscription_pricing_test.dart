import 'package:flutter_test/flutter_test.dart';
import 'package:safy/services/subscription_service.dart';
import 'package:safy/data/models/subscription_model.dart';

void main() {
  group('SubscriptionService pricing (利用者数に応じた課金体系)', () {
    test('20名以下は基本プラン単価100円・上位プラン単価400円', () {
      expect(SubscriptionService.basicPlanUnitPriceYen(20), 100);
      expect(SubscriptionService.upperPlanUnitPriceYen(20), 400);
    });

    test('21〜50名は10%引き(90円/360円)', () {
      expect(SubscriptionService.basicPlanUnitPriceYen(50), 90);
      expect(SubscriptionService.upperPlanUnitPriceYen(50), 360);
    });

    test('51〜100名は20%引き(80円/320円)', () {
      expect(SubscriptionService.basicPlanUnitPriceYen(100), 80);
      expect(SubscriptionService.upperPlanUnitPriceYen(100), 320);
    });

    test('101名以上は個別見積(0円)', () {
      expect(SubscriptionService.basicPlanUnitPriceYen(101), 0);
      expect(SubscriptionService.upperPlanUnitPriceYen(101), 0);
    });

    test('planUnitPriceYen: プラン段階に応じて単価を切り替える', () {
      expect(
        SubscriptionService.planUnitPriceYen(ModulePlanTier.basic, 20),
        100,
      );
      expect(
        SubscriptionService.planUnitPriceYen(ModulePlanTier.upper, 20),
        400,
      );
    });

    test('monthlyPriceYen: 基本プランは単価×人数(モジュール数によらない定額)', () {
      final price = SubscriptionService.monthlyPriceYen(
        headcount: 20,
        planTier: ModulePlanTier.basic,
      );
      expect(price, 100 * 20);
    });

    test('monthlyPriceYen: 上位プランは単価×人数(選択モジュール数によらない定額)', () {
      final price = SubscriptionService.monthlyPriceYen(
        headcount: 50,
        planTier: ModulePlanTier.upper,
      );
      expect(price, 360 * 50);
    });
  });
}
