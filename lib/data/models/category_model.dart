/// 6カテゴリ固定定義（設計書 Section3参照）
enum CategoryId {
  infoMorals, // ①情報モラル
  security, // ②セキュリティ
  privacy, // ③個人情報保護
  infoManagement, // ④情報マネジメント
  compliance, // ⑤コンプライアンス
  aiUsage, // ⑥AI活用
}

class Category {
  final CategoryId id;
  final String name;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  static const List<Category> all = [
    Category(id: CategoryId.infoMorals, name: '情報モラル', sortOrder: 1),
    Category(id: CategoryId.security, name: 'セキュリティ', sortOrder: 2),
    Category(id: CategoryId.privacy, name: '個人情報保護', sortOrder: 3),
    Category(id: CategoryId.infoManagement, name: '情報マネジメント', sortOrder: 4),
    Category(id: CategoryId.compliance, name: 'コンプライアンス', sortOrder: 5),
    Category(id: CategoryId.aiUsage, name: 'AI活用', sortOrder: 6),
  ];

  static Category byId(CategoryId id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);
}
