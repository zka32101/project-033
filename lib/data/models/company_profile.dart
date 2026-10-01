/// 事業の特徴。該当するものにチェックしてもらい、法令上必要な研修を自動で推奨するために使う。
enum BusinessTrait {
  overtime('時間外・休日労働がある', '36協定、割増賃金、長時間労働の管理が必要になります'),
  partTime('パート・アルバイト・契約社員がいる', '同一労働同一賃金、労働条件の明示が必要になります'),
  dispatch('派遣社員を受け入れている', '派遣先としての責任、偽装請負の防止が必要になります'),
  outsourcing('業務を外部に委託している・フリーランスを使う', '取適法、フリーランス新法、委託先の管理が必要になります'),
  personalData('顧客・取引先の個人情報を扱う', '個人情報保護法にもとづく安全管理が必要になります'),
  vehicles('社用車を使う', '安全運転管理者の選任とアルコールチェックが必要になる場合があります'),
  chemicals('化学物質を製造・取り扱う', '化学物質のリスクアセスメント対応が必要になります'),
  outdoorHeat('屋外・高温の場所での作業がある', '熱中症対策の体制整備が必要になります'),
  remote('リモートワーク・在宅勤務がある', '情報セキュリティと労務管理が必要になります'),
  aiUse('業務で生成AIを使う', 'AIの利用ルールと情報漏えい対策が必要になります');

  final String label;
  final String hint;

  const BusinessTrait(this.label, this.hint);

  static BusinessTrait? byName(String name) {
    for (final t in BusinessTrait.values) {
      if (t.name == name) return t;
    }
    return null;
  }
}

/// 会社の規模・事業の特徴。研修の自動推奨と、法令対応チェックリストの適用判定に使う。
/// 契約人数(アプリを使う人数)とは別に、法令の適用基準になる実際の従業員数を持つ。
class CompanyProfile {
  final int employeeCount;
  final Set<BusinessTrait> traits;

  const CompanyProfile({required this.employeeCount, this.traits = const {}});

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      employeeCount: (map['employeeCount'] as num?)?.toInt() ?? 1,
      traits: {
        for (final name in (map['traits'] as List?) ?? const [])
          if (BusinessTrait.byName(name as String) != null) BusinessTrait.byName(name)!,
      },
    );
  }

  Map<String, dynamic> toMap() => {
        'employeeCount': employeeCount,
        'traits': (traits.map((t) => t.name).toList()..sort()),
      };
}
