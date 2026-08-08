import 'category_model.dart';

/// 業種プロファイル（設計書 Section3の優先度テーブルを実データ化）
class Industry {
  final String id;
  final String name;
  final List<CategoryId> highPriority;
  final List<CategoryId> midPriority;
  final List<CategoryId> lowPriority;

  const Industry({
    required this.id,
    required this.name,
    required this.highPriority,
    required this.midPriority,
    required this.lowPriority,
  });

  /// 優先度: high=2, mid=1, low=0
  int priorityOf(CategoryId categoryId) {
    if (highPriority.contains(categoryId)) return 2;
    if (midPriority.contains(categoryId)) return 1;
    return 0;
  }

  factory Industry.fromMap(String id, Map<String, dynamic> map) {
    List<CategoryId> parse(String key) {
      final raw = (map[key] as List?) ?? [];
      return raw
          .map((e) => CategoryId.values.firstWhere(
                (c) => c.name == e,
                orElse: () => CategoryId.infoMorals,
              ))
          .toList();
    }

    return Industry(
      id: id,
      name: map['name'] as String? ?? '',
      highPriority: parse('highPriority'),
      midPriority: parse('midPriority'),
      lowPriority: parse('lowPriority'),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'highPriority': highPriority.map((e) => e.name).toList(),
        'midPriority': midPriority.map((e) => e.name).toList(),
        'lowPriority': lowPriority.map((e) => e.name).toList(),
      };
}
