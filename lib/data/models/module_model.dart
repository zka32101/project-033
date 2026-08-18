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

  const Module({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.passThresholdDefault,
    required this.isFreeTrial,
    required this.sortOrder,
    this.isCustom = false,
  });

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
    );
  }

  Map<String, dynamic> toMap() => {
        'categoryId': categoryId.name,
        'title': title,
        'description': description,
        'passThresholdDefault': passThresholdDefault,
        'isFreeTrial': isFreeTrial,
        'sortOrder': sortOrder,
      };
}
