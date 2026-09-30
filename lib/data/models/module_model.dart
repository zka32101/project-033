import 'category_model.dart';

class Module {
  final String id;
  final CategoryId categoryId;
  final String title;
  final String description;
  final int passThresholdDefault;
  final bool isFreeTrial; // 高優先カテゴリの初回無料モジュール
  final int sortOrder;
  // 会社が作成したオリジナルモジュール(CustomModule)から変換されたものならtrue。
  // レッスン/クイズの取得元(customModules配下 vs グローバルmodules配下)の分岐に使う。
  // グローバルコンテンツのfromMap()では常にfalse(Firestoreには保存しないフィールド)。
  final bool isCustom;
  // 業種専用モジュールの対象業種ID。空なら全業種向け(共通モジュール)。
  final List<String> industryIds;
  // 職種専用モジュールの対象職種ID(JobRole.id)。空なら全職種向け。
  final List<String> roleTags;

  const Module({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.passThresholdDefault,
    required this.isFreeTrial,
    required this.sortOrder,
    this.isCustom = false,
    this.industryIds = const [],
    this.roleTags = const [],
  });

  /// 職種を選んでいる受講者には対象職種のモジュールだけを、未設定の受講者には全てを表示する。
  bool isAvailableForRole(String? jobRole) =>
      roleTags.isEmpty || jobRole == null || roleTags.contains(jobRole);

  /// この業種の受講者に表示するか(共通モジュール、または対象業種に含まれる)。
  bool isAvailableForIndustry(String industryId) =>
      industryIds.isEmpty || industryIds.contains(industryId);

  factory Module.fromMap(String id, Map<String, dynamic> map) {
    return Module(
      id: id,
      categoryId: CategoryId.values.firstWhere(
        (c) => c.name == map['categoryId'],
        orElse: () => CategoryId.infoMorals,
      ),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      passThresholdDefault:
          (map['passThresholdDefault'] as num?)?.toInt() ?? 80,
      isFreeTrial: map['isFreeTrial'] as bool? ?? false,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      industryIds: List<String>.from((map['industryIds'] as List?) ?? const []),
      roleTags: List<String>.from((map['roleTags'] as List?) ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'categoryId': categoryId.name,
        'title': title,
        'description': description,
        'passThresholdDefault': passThresholdDefault,
        'isFreeTrial': isFreeTrial,
        'sortOrder': sortOrder,
        if (industryIds.isNotEmpty) 'industryIds': industryIds,
        if (roleTags.isNotEmpty) 'roleTags': roleTags,
      };
}
