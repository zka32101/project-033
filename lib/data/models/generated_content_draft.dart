/// AIによるオリジナルコンテンツ生成結果のドラフト(未保存)。
/// 管理者が保存前に画面上で編集できるようミュータブルにしている。
class DraftLesson {
  String title;
  String body;

  DraftLesson({required this.title, required this.body});

  factory DraftLesson.fromMap(Map<String, dynamic> map) => DraftLesson(
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
      );
}

class DraftQuizQuestion {
  String question;
  List<String> choices; // 常に4件
  int correctIndex;
  String explanation;

  DraftQuizQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });

  factory DraftQuizQuestion.fromMap(Map<String, dynamic> map) => DraftQuizQuestion(
        question: map['question'] as String? ?? '',
        choices: List<String>.from((map['choices'] as List?) ?? const []),
        correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
        explanation: map['explanation'] as String? ?? '',
      );
}

class GeneratedContentDraft {
  /// 新規モジュール作成モード時のみ値が入る(既存モジュール追加モードではnull)。
  String? moduleTitle;
  String? moduleDescription;
  List<DraftLesson> lessons;
  List<DraftQuizQuestion> quizQuestions;

  GeneratedContentDraft({
    this.moduleTitle,
    this.moduleDescription,
    required this.lessons,
    required this.quizQuestions,
  });

  factory GeneratedContentDraft.fromMap(Map<String, dynamic> map) {
    return GeneratedContentDraft(
      moduleTitle: map['moduleTitle'] as String?,
      moduleDescription: map['moduleDescription'] as String?,
      lessons: (map['lessons'] as List? ?? const [])
          .map((e) => DraftLesson.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      quizQuestions: (map['quizQuestions'] as List? ?? const [])
          .map((e) => DraftQuizQuestion.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
