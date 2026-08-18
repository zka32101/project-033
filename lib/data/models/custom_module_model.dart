import 'category_model.dart';
import 'firestore_date_parser.dart';
import 'module_model.dart';

/// 会社が作成したオリジナルモジュール(プレミアムプラン: 新規モジュール作成)。
/// グローバルなModuleと同じ形のフィールドを持つが、companies/{companyId}/customModules
/// 配下に保存され他社からは見えない。
class CustomModule {
  final String id;
  final String companyId;
  final CategoryId categoryId;
  final String title;
  final String description;
  final int passThresholdDefault;
  final int sortOrder;
  final String createdByEmployeeId;
  final String sourceTheme; // AI生成時に入力したテーマ(監査・再生成の参考用)
  final DateTime createdAt;

  const CustomModule({
    required this.id,
    required this.companyId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.passThresholdDefault,
    required this.sortOrder,
    required this.createdByEmployeeId,
    required this.sourceTheme,
    required this.createdAt,
  });

  factory CustomModule.fromMap(String id, Map<String, dynamic> map) {
    return CustomModule(
      id: id,
      companyId: map['companyId'] as String? ?? '',
      categoryId: CategoryId.values.firstWhere(
        (c) => c.name == map['categoryId'],
        orElse: () => CategoryId.infoMorals,
      ),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      passThresholdDefault: (map['passThresholdDefault'] as num?)?.toInt() ?? 80,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      createdByEmployeeId: map['createdByEmployeeId'] as String? ?? '',
      sourceTheme: map['sourceTheme'] as String? ?? '',
      createdAt: parseFirestoreDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'companyId': companyId,
        'categoryId': categoryId.name,
        'title': title,
        'description': description,
        'passThresholdDefault': passThresholdDefault,
        'sortOrder': sortOrder,
        'createdByEmployeeId': createdByEmployeeId,
        'sourceTheme': sourceTheme,
        'createdAt': createdAt,
      };

  /// 既存画面(ホーム/管理者ダッシュボード等)がModuleとして扱えるように変換する。
  /// isFreeTrialは常にfalse(オリジナルコンテンツは無料体験の対象外)。
  Module toModule() => Module(
        id: id,
        categoryId: categoryId,
        title: title,
        description: description,
        passThresholdDefault: passThresholdDefault,
        isFreeTrial: false,
        sortOrder: sortOrder,
        isCustom: true,
      );
}
