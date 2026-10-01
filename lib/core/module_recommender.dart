import '../data/models/category_model.dart';
import '../data/models/company_profile.dart';
import '../data/models/compliance_item.dart';
import '../data/models/industry_model.dart';
import '../data/models/module_model.dart';

/// 推奨の強さ。required=必須(法令・業種上の理由)、recommended=推奨、optional=任意。
enum RecommendationLevel { required, recommended, optional }

class ModuleRecommendation {
  final RecommendationLevel level;

  /// 推奨の理由(画面に表示する。重複なし・出現順)。
  final List<String> reasons;

  const ModuleRecommendation(this.level, this.reasons);

  /// あらかじめチェックを入れておくか。
  bool get preselected => level != RecommendationLevel.optional;
}

/// 会社の規模・事業の特徴・業種から、受講させる研修を推奨する純粋ロジック。
/// 「法令で必要」は法令チェックリスト(従業員数・条件)、事業の特徴に応じた研修、業種専用研修から、
/// 「推奨」は業種の重点分野から判定する。
class ModuleRecommender {
  const ModuleRecommender._();

  /// 事業の特徴ごとに追加で必要になる研修。`required`=法令上の要請が強いもの。
  static const Map<BusinessTrait, ({bool required, List<String> moduleIds})> traitModules = {
    BusinessTrait.overtime: (required: true, moduleIds: ['m_law_workstyle', 'm_mental_overwork']),
    BusinessTrait.partTime: (required: true, moduleIds: ['m_law_equal_treatment']),
    BusinessTrait.dispatch: (required: true, moduleIds: ['m_law_dispatch']),
    BusinessTrait.outsourcing: (
      required: true,
      moduleIds: ['m_privacy_outsourcing', 'm_compliance_freelance', 'm_compliance_labor'],
    ),
    BusinessTrait.personalData: (required: true, moduleIds: ['m_privacy_basics', 'm_privacy_customer']),
    BusinessTrait.vehicles: (required: true, moduleIds: ['m_law_company_vehicle']),
    BusinessTrait.chemicals: (required: true, moduleIds: ['m_law_chemical']),
    BusinessTrait.outdoorHeat: (required: true, moduleIds: ['m_health_heatstroke']),
    BusinessTrait.remote: (
      required: false,
      moduleIds: ['m_ethics_remote', 'm_security_device', 'm_infomgmt_byod'],
    ),
    BusinessTrait.aiUse: (
      required: false,
      moduleIds: ['m_ai_basics', 'm_ai_ethics', 'm_ai_data', 'm_ai_guideline', 'm_ai_customer'],
    ),
  };

  static RecommendationLevel _max(RecommendationLevel a, RecommendationLevel b) =>
      a.index <= b.index ? a : b; // index が小さいほど強い(required=0)

  static Map<String, ModuleRecommendation> recommend({
    required List<Module> modules,
    required Industry industry,
    required CompanyProfile profile,
    required List<ComplianceItem> checklistItems,
    Map<String, int> categoryPriorityOverride = const {},
  }) {
    final levels = <String, RecommendationLevel>{};
    final reasons = <String, List<String>>{};

    void add(String moduleId, RecommendationLevel level, String reason) {
      levels[moduleId] = levels.containsKey(moduleId) ? _max(levels[moduleId]!, level) : level;
      final list = reasons.putIfAbsent(moduleId, () => []);
      if (!list.contains(reason)) list.add(reason);
    }

    // 1) 法令チェックリスト: 従業員数・事業の特徴で適用される項目に関連する研修。
    for (final item in checklistItems) {
      if (!item.appliesTo(profile.employeeCount, traits: profile.traits)) continue;
      final level = item.isMandatory ? RecommendationLevel.required : RecommendationLevel.recommended;
      final prefix = item.isMandatory ? '法令' : '推奨';
      for (final id in item.relatedModuleIds) {
        add(id, level, '$prefix: ${item.title}(${item.law})');
      }
    }

    // 2) 事業の特徴に応じた研修。
    for (final trait in profile.traits) {
      final def = traitModules[trait];
      if (def == null) continue;
      final level = def.required ? RecommendationLevel.required : RecommendationLevel.recommended;
      for (final id in def.moduleIds) {
        add(id, level, '事業の特徴: ${trait.label}');
      }
    }

    // 3) 業種専用の研修(その業種向けに作られたもの)と、業種の重点分野。
    for (final m in modules) {
      if (m.industryIds.isNotEmpty && m.industryIds.contains(industry.id)) {
        add(m.id, RecommendationLevel.required, '業種専用の研修(${industry.name})');
      }
      final override = categoryPriorityOverride[m.categoryId.name];
      final priority = override ?? industry.priorityOf(m.categoryId);
      if (priority == 2) {
        add(m.id, RecommendationLevel.recommended, '${industry.name}の重点分野(${_categoryName(m.categoryId)})');
      }
    }

    final result = <String, ModuleRecommendation>{};
    for (final m in modules) {
      final level = levels[m.id] ?? RecommendationLevel.optional;
      result[m.id] = ModuleRecommendation(level, reasons[m.id] ?? const []);
    }
    return result;
  }

  static String _categoryName(CategoryId id) =>
      Category.all.firstWhere((c) => c.id == id).name;

  /// あらかじめチェックを入れる研修のID(必須+推奨)。
  static Set<String> preselectedIds(Map<String, ModuleRecommendation> recommendations) => {
        for (final e in recommendations.entries)
          if (e.value.preselected) e.key,
      };
}
