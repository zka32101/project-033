/// AIによるオリジナルコンテンツ生成結果のドラフト(未保存)。
/// 管理者が保存前に画面上で編集できるようミュータブルにしている。
class DraftLesson {
  /// 保存済みのレッスンを編集するときのドキュメントID(新規はnull)。
  String? id;
  String title;
  String body;

  DraftLesson({this.id, required this.title, required this.body});

  factory DraftLesson.blank() => DraftLesson(title: '', body: '');

  factory DraftLesson.fromMap(Map<String, dynamic> map) => DraftLesson(
        title: map['title'] as String? ?? '',
        body: map['body'] as String? ?? '',
      );
}

class DraftQuizQuestion {
  /// 保存済みの問題を編集するときのドキュメントID(新規はnull)。
  String? id;
  String question;
  List<String> choices; // 常に4件
  int correctIndex;
  String explanation;

  DraftQuizQuestion({
    this.id,
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });

  factory DraftQuizQuestion.blank() => DraftQuizQuestion(
        question: '',
        choices: ['', '', '', ''],
        correctIndex: 0,
        explanation: '',
      );

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

/// 手で作成・編集した内容の検証と整形。
class ContentDraftValidator {
  const ContentDraftValidator._();

  static const maxChoices = 4;
  static const minChoices = 2;

  /// 保存できない理由を返す(問題なければ空)。
  static List<String> validate(GeneratedContentDraft draft, {required bool requireModuleTitle}) {
    final errors = <String>[];
    if (requireModuleTitle && (draft.moduleTitle ?? '').trim().isEmpty) {
      errors.add('研修のタイトルを入力してください');
    }
    if (draft.lessons.isEmpty && draft.quizQuestions.isEmpty) {
      errors.add('レッスンまたは問題を1つ以上追加してください');
    }
    for (var i = 0; i < draft.lessons.length; i++) {
      final l = draft.lessons[i];
      if (l.title.trim().isEmpty || l.body.trim().isEmpty) {
        errors.add('レッスン${i + 1}: タイトルと本文を入力してください');
      }
    }
    for (var i = 0; i < draft.quizQuestions.length; i++) {
      final q = draft.quizQuestions[i];
      if (q.question.trim().isEmpty) {
        errors.add('問題${i + 1}: 問題文を入力してください');
        continue;
      }
      final filled = q.choices.where((c) => c.trim().isNotEmpty).length;
      if (filled < minChoices) {
        errors.add('問題${i + 1}: 選択肢を$minChoicesつ以上入力してください');
        continue;
      }
      final correct = q.correctIndex;
      if (correct < 0 || correct >= q.choices.length || q.choices[correct].trim().isEmpty) {
        errors.add('問題${i + 1}: 正解に、入力済みの選択肢を選んでください');
      }
    }
    return errors;
  }

  /// 空の選択肢を詰め、正解の位置を合わせる(検証済みの内容に対して使う)。
  static void normalize(GeneratedContentDraft draft) {
    draft.moduleTitle = draft.moduleTitle?.trim();
    draft.moduleDescription = draft.moduleDescription?.trim();
    for (final l in draft.lessons) {
      l.title = l.title.trim();
      l.body = l.body.trim();
    }
    for (final q in draft.quizQuestions) {
      final correctText = q.choices[q.correctIndex].trim();
      final kept = q.choices.map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
      q.choices = kept;
      q.correctIndex = kept.indexOf(correctText);
      q.question = q.question.trim();
      q.explanation = q.explanation.trim();
    }
  }
}
