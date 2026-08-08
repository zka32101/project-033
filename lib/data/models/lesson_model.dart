class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String body; // 説明ページの詳解・図解コンテンツ(Markdown可)
  final List<String> imageUrls;
  final int sortOrder;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.body,
    required this.imageUrls,
    required this.sortOrder,
  });

  factory Lesson.fromMap(String id, Map<String, dynamic> map) {
    return Lesson(
      id: id,
      moduleId: map['moduleId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      imageUrls: List<String>.from((map['imageUrls'] as List?) ?? []),
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'moduleId': moduleId,
        'title': title,
        'body': body,
        'imageUrls': imageUrls,
        'sortOrder': sortOrder,
      };
}
