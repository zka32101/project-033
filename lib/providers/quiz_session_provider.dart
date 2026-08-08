import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/quiz_question_model.dart';

/// 受講中のクイズの回答状態を保持する（結果画面表示前の一時状態）
class QuizSessionState {
  final List<QuizQuestion> questions;
  final Map<int, int> selectedAnswers; // questionIndex -> choiceIndex
  final int currentIndex;
  final bool isSubmitting; // 送信中の二重タップ防止用

  const QuizSessionState({
    required this.questions,
    this.selectedAnswers = const {},
    this.currentIndex = 0,
    this.isSubmitting = false,
  });

  bool get isLastQuestion => currentIndex >= questions.length - 1;
  bool get isAllAnswered => selectedAnswers.length == questions.length;

  List<int> answersInOrder() =>
      List.generate(questions.length, (i) => selectedAnswers[i] ?? -1);

  QuizSessionState copyWith({
    Map<int, int>? selectedAnswers,
    int? currentIndex,
    bool? isSubmitting,
  }) {
    return QuizSessionState(
      questions: questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      currentIndex: currentIndex ?? this.currentIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class QuizSessionNotifier extends StateNotifier<QuizSessionState> {
  QuizSessionNotifier(List<QuizQuestion> questions)
      : super(QuizSessionState(questions: questions));

  void selectAnswer(int choiceIndex) {
    final updated = {...state.selectedAnswers, state.currentIndex: choiceIndex};
    state = state.copyWith(selectedAnswers: updated);
  }

  void nextQuestion() {
    if (state.isLastQuestion) return;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
  }

  void setSubmitting(bool value) {
    state = state.copyWith(isSubmitting: value);
  }

  void reset(List<QuizQuestion> questions) {
    state = QuizSessionState(questions: questions);
  }
}

final quizSessionProvider =
    StateNotifierProvider.family<QuizSessionNotifier, QuizSessionState, List<QuizQuestion>>(
  (ref, questions) => QuizSessionNotifier(questions),
);
