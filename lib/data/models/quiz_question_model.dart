class QuizQuestion {
  final String id;
  final String moduleId;
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.moduleId,
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  factory QuizQuestion.fromMap(String id, Map<String, dynamic> map) {
    return QuizQuestion(
      id: id,
      moduleId: map['moduleId'] as String? ?? '',
      question: map['question'] as String? ?? '',
      choices: List<String>.from((map['choices'] as List?) ?? []),
      correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: map['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'moduleId': moduleId,
        'question': question,
        'choices': choices,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}
