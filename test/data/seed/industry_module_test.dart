import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/seed/industries_seed.dart';
import 'package:safy/data/seed/modules_seed.dart';

void main() {
  test('業種専用モジュールの対象業種は実在する業種IDだけを指す', () {
    final ids = seedIndustries.map((i) => i.id).toSet();
    for (final m in seedModules.where((m) => m.industryIds.isNotEmpty)) {
      expect(ids.containsAll(m.industryIds), isTrue, reason: m.id);
    }
  });

  test('業種専用モジュールは対象業種にだけ表示され、共通モジュールは全業種に表示される', () {
    final construction = seedModules.firstWhere((m) => m.id == 'm_ind_construction_safety');
    expect(construction.isAvailableForIndustry('construction'), isTrue);
    expect(construction.isAvailableForIndustry('retail'), isFalse);
    final common = seedModules.firstWhere((m) => m.industryIds.isEmpty);
    expect(common.isAvailableForIndustry('retail'), isTrue);
  });

  test('8業種それぞれに専用モジュールが1件以上ある', () {
    for (final i in seedIndustries) {
      expect(
        seedModules.any((m) => m.industryIds.contains(i.id)),
        isTrue,
        reason: i.id,
      );
    }
  });
}
