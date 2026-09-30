/// 法令対応チェックリストの分類。
enum ComplianceCategory {
  labor('労務・労働時間'),
  insurance('保険・届出'),
  safety('安全衛生'),
  inclusion('雇用・両立支援'),
  dataTrade('個人情報・取引'),
  resilience('セキュリティ・BCP(推奨)');

  final String label;

  const ComplianceCategory(this.label);
}

/// 会社が実施すべきこと(届出・規程・選任・記録など)1項目。
/// 適用は従業員数(minHeadcount以上)と、必要に応じて条件(condition)で決まる。
class ComplianceItem {
  final String id;
  final ComplianceCategory category;
  final String title;
  final String description;

  /// 根拠となる法令(一般的な目安)。
  final String law;

  /// この人数以上の事業場に適用される(全事業場なら1)。
  final int minHeadcount;

  /// 法令上の義務ならtrue。努力義務・推奨ならfalse。
  final bool isMandatory;

  /// 適用される条件(「社用車を5台以上使用する場合」など)。無条件ならnull。
  final String? condition;

  /// 関連する研修モジュールのID。
  final List<String> relatedModuleIds;

  const ComplianceItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.law,
    this.minHeadcount = 1,
    this.isMandatory = true,
    this.condition,
    this.relatedModuleIds = const [],
  });

  bool appliesTo(int headcount) => headcount >= minHeadcount;
}
