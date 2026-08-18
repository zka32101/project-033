import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/industry_model.dart';
import 'package:safy/data/models/category_model.dart';

void main() {
  group('Industry.priorityOf', () {
    final manufacturing = Industry(
      id: 'manufacturing',
      name: '製造業',
      highPriority: [CategoryId.security, CategoryId.infoManagement],
      midPriority: [CategoryId.compliance, CategoryId.privacy],
      lowPriority: [CategoryId.infoMorals, CategoryId.aiUsage],
    );

    test('高優先カテゴリは2', () {
      expect(manufacturing.priorityOf(CategoryId.security), 2);
    });

    test('中優先カテゴリは1', () {
      expect(manufacturing.priorityOf(CategoryId.compliance), 1);
    });

    test('低優先カテゴリは0', () {
      expect(manufacturing.priorityOf(CategoryId.infoMorals), 0);
    });

    test('fromMap/toMapのラウンドトリップが一致する', () {
      final map = manufacturing.toMap();
      final restored = Industry.fromMap('manufacturing', map);
      expect(restored.highPriority, manufacturing.highPriority);
      expect(restored.midPriority, manufacturing.midPriority);
      expect(restored.lowPriority, manufacturing.lowPriority);
    });
  });
}
