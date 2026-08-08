import 'package:flutter_test/flutter_test.dart';
import 'package:anzet/core/category_priority_resolver.dart';
import 'package:anzet/data/models/category_model.dart';
import 'package:anzet/data/models/industry_model.dart';

void main() {
  final industry = const Industry(
    id: 'manufacturing',
    name: '製造業',
    highPriority: [CategoryId.security],
    midPriority: [CategoryId.compliance],
    lowPriority: [CategoryId.aiUsage],
  );

  group('CategoryPriorityResolver.resolve', () {
    test('上書きが無ければ業種プロファイルの優先度をそのまま返す', () {
      final result = CategoryPriorityResolver.resolve(
        industry: industry,
        categoryId: CategoryId.security,
        overrides: const {},
      );
      expect(result, 2);
    });

    test('上書きがあればそちらを優先する', () {
      final result = CategoryPriorityResolver.resolve(
        industry: industry,
        categoryId: CategoryId.security,
        overrides: const {'security': 0},
      );
      expect(result, 0);
    });

    test('上書きに存在しないカテゴリは業種プロファイルの値にフォールバックする', () {
      final result = CategoryPriorityResolver.resolve(
        industry: industry,
        categoryId: CategoryId.privacy,
        overrides: const {'security': 0},
      );
      expect(result, 0); // privacyはhigh/mid/lowいずれにも含まれないためlow=0
    });
  });
}
