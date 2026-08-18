import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/module_model.dart';
import '../../data/models/lesson_model.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../quiz/quiz_screen.dart';
import '../../widgets/error_retry_view.dart';

/// 説明ページ(Lessonの詳解・図解)。最後まで読むとクイズへ進める。
class LessonScreen extends ConsumerStatefulWidget {
  final Module module;

  const LessonScreen({super.key, required this.module});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _currentPage = 0;
  bool _hasStarted = false;
  late Future<List<Lesson>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    // futureをbuild()内で毎回生成すると、ページ送りのsetStateのたびに再取得され
    // 本文がロード中表示に戻ってしまうため、モジュールごとに一度だけ取得してキャッシュする。
    _lessonsFuture = _fetchLessons();
  }

  Future<List<Lesson>> _fetchLessons() {
    final companyId = ref.read(sessionProvider).company?.id;
    if (widget.module.isCustom) {
      // オリジナルモジュールはcustomModules配下にのみレッスンが存在する。
      return ref
          .read(customContentServiceProvider)
          .listCustomModuleLessons(companyId!, widget.module.id);
    }
    if (companyId == null) {
      return ref.read(contentServiceProvider).listLessons(widget.module.id);
    }
    // グローバルモジュール+会社が追加したオリジナルコンテンツ(あれば)を連結する。
    return ref
        .read(contentServiceProvider)
        .listLessonsForCompany(widget.module.id, companyId);
  }

  Future<void> _ensureEnrollmentStarted() async {
    if (_hasStarted) return;
    _hasStarted = true;
    final session = ref.read(sessionProvider);
    if (!session.isSignedIn) return;
    try {
      await ref.read(enrollmentServiceProvider).startModule(
            companyId: session.company!.id,
            employeeId: session.employee!.id,
            moduleId: widget.module.id,
          );
      await ref.read(analyticsServiceProvider).logAhaMomentReached(
            companyId: session.company!.id,
            moduleId: widget.module.id,
          );
    } catch (_) {
      // 受講記録の開始に失敗しても学習自体は継続できるようにする(次回アクセス時に再試行される)。
      _hasStarted = false;
    }
  }

  Future<void> _markLessonViewed(String lessonId) async {
    final session = ref.read(sessionProvider);
    if (!session.isSignedIn) return;
    try {
      await ref.read(enrollmentServiceProvider).recordLessonViewed(
            companyId: session.company!.id,
            employeeId: session.employee!.id,
            moduleId: widget.module.id,
            lessonId: lessonId,
          );
    } catch (_) {
      // 進捗記録に失敗しても学習の進行自体は妨げない(記録は次回アクセス時に補完される)。
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureEnrollmentStarted();

    return Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      body: FutureBuilder<List<Lesson>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorRetryView(
              message: 'レッスンの読み込みに失敗しました',
              onRetry: () => setState(() {
                _lessonsFuture = _fetchLessons();
              }),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lessons = snapshot.data!;
          if (lessons.isEmpty) {
            return const Center(child: Text('レッスンがまだ登録されていません'));
          }
          final lesson = lessons[_currentPage];
          final isLast = _currentPage == lessons.length - 1;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / lessons.length,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_currentPage + 1}/${lessons.length}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              lesson.body,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(height: 1.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await _markLessonViewed(lesson.id);
                      if (isLast) {
                        if (!context.mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(module: widget.module),
                          ),
                        );
                      } else {
                        setState(() => _currentPage++);
                      }
                    },
                    child: Text(isLast ? 'クイズに進む' : '次へ'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
