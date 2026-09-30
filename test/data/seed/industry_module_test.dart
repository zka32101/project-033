import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/job_role.dart';
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

  test('職種専用モジュールのroleTagsは実在する職種IDだけを指し、各職種に1件以上ある', () {
    final ids = JobRole.all.map((r) => r.id).toSet();
    for (final m in seedModules.where((m) => m.roleTags.isNotEmpty)) {
      expect(ids.containsAll(m.roleTags), isTrue, reason: m.id);
    }
    for (final r in JobRole.all) {
      expect(seedModules.any((m) => m.roleTags.contains(r.id)), isTrue, reason: r.id);
    }
  });

  test('職種を選ぶと対象職種と共通のモジュールだけ、未設定なら全て表示される', () {
    final acct = seedModules.firstWhere((m) => m.id == 'm_role_accounting_bec');
    expect(acct.isAvailableForRole('accounting'), isTrue);
    expect(acct.isAvailableForRole('sales'), isFalse);
    expect(acct.isAvailableForRole(null), isTrue);
    final common = seedModules.firstWhere((m) => m.roleTags.isEmpty);
    expect(common.isAvailableForRole('sales'), isTrue);
  });
}
