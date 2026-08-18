import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/module_model.dart';
import '../../data/models/quiz_question_model.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/quiz_session_provider.dart';
import '../result/result_screen.dart';
import '../../widgets/error_retry_view.dart';

/// クイズモード(○問中○点以上で合格)。設計書Step5.5: 否定的な演出は避ける。
class QuizScreen extends ConsumerWidget {
  final Module module;

  const QuizScreen({super.key, required this.module});

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    List<QuizQuestion> questions,
    List<int> answers,
  ) async {
    final session = ref.read(sessionProvider);
    if (!session.isSignedIn) return;
    final notifier = ref.read(quizSessionProvider(questions).notifier);
    notifier.setSubmitting(true); // 二重タップによる多重送信を防ぐ
    final company = session.company!;
    final threshold = company.passThresholdFor(
      module.id,
      moduleDefault: module.passThresholdDefault,
    );

    QuizAttempt attempt;
    try {
      attempt = await ref.read(quizServiceProvider).submitAttempt(
            companyId: company.id,
            employeeId: session.employee!.id,
            moduleId: module.id,
            selectedAnswers: answers,
          );
    } catch (_) {
      // Cloud Functions未デプロイ環境向けフォールバック(クライアント側判定・保存はスキップ)。
      // Firebase/Cloud Functions本番設定完了後は常にsubmitAttempt経路が使われる。
      attempt = ref.read(quizServiceProvider).previewResult(
            employeeId: session.employee!.id,
            moduleId: module.id,
            selectedAnswers: answers,
            questions: questions,
            thresholdApplied: threshold,
          );
    }

    try {
      await ref.read(analyticsServiceProvider).logQuizAnswered(
            companyId: company.id,
            moduleId: module.id,
            questionId: 'summary',
            correct: attempt.passed,
          );
    } catch (_) {
      // 計測ログの送信失敗は結果画面への遷移を妨げない。
    }

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(module: module, attempt: attempt),
      ),
    );
  }

  Future<List<QuizQuestion>> _fetchQuizQuestions(WidgetRef ref) {
    final companyId = ref.read(sessionProvider).company?.id;
    if (module.isCustom) {
      // オリジナルモジュールはcustomModules配下にのみクイズ問題が存在する。
      return ref
          .read(customContentServiceProvider)
          .listCustomModuleQuizQuestions(companyId!, module.id);
    }
    if (companyId == null) {
      return ref.read(contentServiceProvider).listQuizQuestions(module.id);
    }
    // グローバル問題+会社が追加したオリジナル問題(あれば)を連結する。
    // submitQuizAttempt Cloud Function側の合算順序(グローバル→追加)と一致させること。
    return ref
        .read(contentServiceProvider)
        .listQuizQuestionsForCompany(module.id, companyId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<QuizQuestion>>(
      future: _fetchQuizQuestions(ref),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
              body: ErrorRetryView(message: '問題の読み込みに失敗しました'));
        }
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final questions = snapshot.data!;
        if (questions.isEmpty) {
          return const Scaffold(body: Center(child: Text('問題が登録されていません')));
        }

        return Consumer(
          builder: (context, ref, _) {
            final sessionState = ref.watch(quizSessionProvider(questions));
            final notifier =
                ref.read(quizSessionProvider(questions).notifier);
            final question = sessionState.questions[sessionState.currentIndex];
            final selected = sessionState.selectedAnswers[sessionState.currentIndex];

            final colorScheme = Theme.of(context).colorScheme;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                    '問題 ${sessionState.currentIndex + 1}/${sessionState.questions.length}'),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (sessionState.currentIndex + 1) /
                            sessionState.questions.length,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(question.question,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                    const SizedBox(height: 16),
                    RadioGroup<int>(
                      groupValue: selected,
                      onChanged: (value) => notifier.selectAnswer(value!),
                      child: Column(
                        children: List.generate(question.choices.length, (i) {
                          final isSelected = selected == i;
                          return Card(
                            color: isSelected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerLow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: RadioListTile<int>(
                              title: Text(question.choices[i]),
                              value: i,
                            ),
                          );
                        }),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: (selected == null || sessionState.isSubmitting)
                            ? null
                            : () {
                                if (sessionState.isLastQuestion) {
                                  _submit(context, ref, questions,
                                      sessionState.answersInOrder());
                                } else {
                                  notifier.nextQuestion();
                                }
                              },
                        child: sessionState.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(sessionState.isLastQuestion ? '回答を送信する' : '次の問題へ'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
