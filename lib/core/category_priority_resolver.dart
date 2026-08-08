import '../data/models/category_model.dart';
import '../data/models/industry_model.dart';

/// 業種プロファイルの優先度は業界横断の初期値であり、実際の会社ごとの重点分野は
/// 異なる場合があるため、Company側の個別上書き(categoryPriorityOverride)があれば
/// そちらを優先して解決する純粋ロジック。
class CategoryPriorityResolver {
  static int resolve({
    required Industry industry,
    required CategoryId categoryId,
    required Map<String, int> overrides,
  }) {
    final override = overrides[categoryId.name];
    if (override != null) return override;
    return industry.priorityOf(categoryId);
  }
}
