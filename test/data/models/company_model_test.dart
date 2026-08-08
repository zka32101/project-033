import 'package:flutter_test/flutter_test.dart';
import 'package:anzet/data/models/company_model.dart';

void main() {
  group('Company.recommendedPassThreshold', () {
    test('20名以下は70%推奨', () {
      final c = Company(
        id: 'c1',
        name: 'テスト社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 20,
        customPassThreshold: {},
        createdAt: DateTime(2026, 1, 1),
      );
      expect(c.recommendedPassThreshold(), 70);
    });

    test('21〜100名は80%推奨', () {
      final c = Company(
        id: 'c2',
        name: 'テスト社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 100,
        customPassThreshold: {},
        createdAt: DateTime(2026, 1, 1),
      );
      expect(c.recommendedPassThreshold(), 80);
    });

    test('101名以上は90%推奨', () {
      final c = Company(
        id: 'c3',
        name: 'テスト社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 101,
        customPassThreshold: {},
        createdAt: DateTime(2026, 1, 1),
      );
      expect(c.recommendedPassThreshold(), 90);
    });

    test('customPassThresholdが設定されていればそちらを優先', () {
      final c = Company(
        id: 'c4',
        name: 'テスト社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 20,
        customPassThreshold: {'moduleA': 90},
        createdAt: DateTime(2026, 1, 1),
      );
      expect(c.passThresholdFor('moduleA', moduleDefault: 80), 90);
      expect(c.passThresholdFor('moduleB', moduleDefault: 80), 80);
    });
  });

  group('Company.contactEmail', () {
    test('未設定時は空文字、fromMap/toMapのラウンドトリップが一致する', () {
      final c = Company(
        id: 'c5',
        name: 'テスト社',
        industryId: 'manufacturing',
        planType: PlanType.team,
        contractedHeadcount: 20,
        customPassThreshold: const {},
        createdAt: DateTime(2026, 1, 1),
      );
      expect(c.contactEmail, '');

      final withEmail = c.copyWith(contactEmail: 'admin@example.com');
      final restored = Company.fromMap(withEmail.id, withEmail.toMap());
      expect(restored.contactEmail, 'admin@example.com');
    });
  });
}
