import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/seed/compliance_checklist_seed.dart';
import 'package:safy/data/seed/modules_seed.dart';
import 'package:safy/services/compliance_checklist_service.dart';

void main() {
  test('項目IDに重複がなく、関連モジュールは実在する', () {
    final ids = seedComplianceItems.map((i) => i.id).toList();
    expect(ids.toSet().length, ids.length);
    final moduleIds = seedModules.map((m) => m.id).toSet();
    for (final item in seedComplianceItems) {
      for (final id in item.relatedModuleIds) {
        expect(moduleIds.contains(id), isTrue, reason: '${item.id} -> $id');
      }
      expect(item.title.isNotEmpty && item.description.isNotEmpty && item.law.isNotEmpty, isTrue);
    }
  });

  test('従業員数によって対象の項目が変わる', () {
    List<String> applicable(int n) =>
        seedComplianceItems.where((i) => i.appliesTo(n)).map((i) => i.id).toList();
    expect(applicable(5), contains('c_labor_contract'));
    expect(applicable(5), isNot(contains('c_work_rules')));
    expect(applicable(10), contains('c_work_rules'));
    expect(applicable(49), isNot(contains('c_hygiene_manager')));
    expect(applicable(50), contains('c_hygiene_manager'));
    expect(applicable(100), isNot(contains('c_action_plan')));
    expect(applicable(101), contains('c_action_plan'));
    expect(applicable(300), isNot(contains('c_whistleblowing')));
    expect(applicable(301), contains('c_whistleblowing'));
  });

  test('実施状況を会社ごとに保存・取得できる', () async {
    final service = ComplianceChecklistService(FakeFirebaseFirestore());
    await service.setDone(companyId: 'A', itemId: 'c_records', done: true);
    await service.setDone(companyId: 'A', itemId: 'c_privacy', done: true);
    await service.setDone(companyId: 'A', itemId: 'c_privacy', done: false);
    await service.setDone(companyId: 'B', itemId: 'c_records', done: true);

    expect(await service.watchStatuses('A').first, {'c_records': true, 'c_privacy': false});
    expect(await service.watchStatuses('B').first, {'c_records': true});
  });
}
