import 'package:flutter_test/flutter_test.dart';
import 'package:anzet/services/subscription_service.dart';

void main() {
  group('SubscriptionService pricing (設計書 Section2)', () {
    test('20名以下はモジュール単価100円・セット400円', () {
      expect(SubscriptionService.moduleUnitPriceYen(20), 100);
      expect(SubscriptionService.fullSetUnitPriceYen(20), 400);
    });

    test('21〜50名は10%引き(90円/360円)', () {
      expect(SubscriptionService.moduleUnitPriceYen(50), 90);
      expect(SubscriptionService.fullSetUnitPriceYen(50), 360);
    });

    test('51〜100名は20%引き(80円/320円)', () {
      expect(SubscriptionService.moduleUnitPriceYen(100), 80);
      expect(SubscriptionService.fullSetUnitPriceYen(100), 320);
    });

    test('monthlyPriceYen: モジュール個別選択は 単価×モジュール数×人数', () {
      final price = SubscriptionService.monthlyPriceYen(
        headcount: 20,
        moduleCount: 3,
        fullSet: false,
      );
      expect(price, 100 * 3 * 20);
    });

    test('monthlyPriceYen: セット契約は セット単価×人数', () {
      final price = SubscriptionService.monthlyPriceYen(
        headcount: 50,
        moduleCount: 6,
        fullSet: true,
      );
      expect(price, 360 * 50);
    });
  });
}
