import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/module_recommender.dart';
import 'package:safy/data/models/company_profile.dart';
import 'package:safy/data/models/industry_model.dart';
import 'package:safy/data/seed/compliance_checklist_seed.dart';
import 'package:safy/data/seed/industries_seed.dart';
import 'package:safy/data/seed/modules_seed.dart';

Industry _industry(String id) => seedIndustries.firstWhere((i) => i.id == id);

Map<String, ModuleRecommendation> _recommend(
  String industryId,
  int employees, [
  Set<BusinessTrait> traits = const {},
]) {
  final industry = _industry(industryId);
  return ModuleRecommender.recommend(
    modules: seedModules.where((m) => m.isAvailableForIndustry(industryId)).toList(),
    industry: industry,
    profile: CompanyProfile(employeeCount: employees, traits: traits),
    checklistItems: seedComplianceItems,
  );
}

void main() {
  final moduleIds = seedModules.map((m) => m.id).toSet();

  test('推奨ロジックが参照する研修IDはすべて実在する', () {
    for (final def in ModuleRecommender.traitModules.values) {
      for (final id in def.moduleIds) {
        expect(moduleIds, contains(id));
      }
    }
    for (final item in seedComplianceItems) {
      for (final id in item.relatedModuleIds) {
        expect(moduleIds, contains(id), reason: '${item.id} の関連研修');
      }
    }
  });

  test('事業の特徴の全種類に、対応する研修の定義がある', () {
    expect(ModuleRecommender.traitModules.keys.toSet(), BusinessTrait.values.toSet());
  });

  test('従業員数が基準に満たない小規模では就業規則の研修は必須にならず、10名以上で必須になる', () {
    expect(_recommend('retail', 5)['m_law_work_rules']!.level, isNot(RecommendationLevel.required));
    final r = _recommend('retail', 10)['m_law_work_rules']!;
    expect(r.level, RecommendationLevel.required);
    expect(r.reasons.first, contains('就業規則'));
  });

  test('社用車を使う会社だけ、安全運転管理の研修が必須になる', () {
    expect(_recommend('retail', 20)['m_law_company_vehicle']!.level, isNot(RecommendationLevel.required));
    final r = _recommend('retail', 20, {BusinessTrait.vehicles})['m_law_company_vehicle']!;
    expect(r.level, RecommendationLevel.required);
    expect(r.reasons.join(), contains('社用車'));
  });

  test('化学物質・外部委託・派遣も、該当する会社だけ必須になる', () {
    final none = _recommend('manufacturing', 30);
    final all = _recommend('manufacturing', 30, {
      BusinessTrait.chemicals,
      BusinessTrait.outsourcing,
      BusinessTrait.dispatch,
    });
    for (final id in ['m_law_chemical', 'm_law_dispatch', 'm_compliance_freelance']) {
      expect(none[id]!.level, isNot(RecommendationLevel.required), reason: id);
      expect(all[id]!.level, RecommendationLevel.required, reason: id);
    }
  });

  test('生成AI・リモートは推奨(必須にはならない)', () {
    final r = _recommend('it', 20, {BusinessTrait.aiUse, BusinessTrait.remote});
    expect(r['m_ai_guideline']!.level, isNot(RecommendationLevel.optional));
    expect(r['m_ethics_remote']!.level, isNot(RecommendationLevel.optional));
  });

  test('業種専用の研修は、その業種で必須になる', () {
    final r = _recommend('construction', 20);
    expect(r['m_ind_construction_safety']!.level, RecommendationLevel.required);
    expect(r['m_ind_construction_safety']!.reasons.join(), contains('業種専用'));
  });

  test('理由は重複せず、研修ごとに付く', () {
    final r = _recommend('manufacturing', 60, BusinessTrait.values.toSet());
    for (final e in r.entries) {
      expect(e.value.reasons.toSet().length, e.value.reasons.length, reason: e.key);
      if (e.value.level != RecommendationLevel.optional) {
        expect(e.value.reasons, isNotEmpty, reason: e.key);
      }
    }
  });

  test('規模・特徴が増えるほど、あらかじめチェックされる研修が増える', () {
    int count(String ind, int n, Set<BusinessTrait> t) =>
        ModuleRecommender.preselectedIds(_recommend(ind, n, t)).length;
    final small = count('retail', 3, {});
    final mid = count('retail', 30, {BusinessTrait.personalData});
    final big = count('retail', 300, BusinessTrait.values.toSet());
    // ignore: avoid_print
    print('小規模=$small 中規模=$mid 大規模(全特徴)=$big / 全${seedModules.length}件');
    expect(small, lessThan(mid));
    expect(mid, lessThan(big));
    expect(big, lessThan(seedModules.length)); // 全部をチェックする推奨にはならない
  });
}
