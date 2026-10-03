import 'package:flutter/material.dart';
import '../../../data/models/generated_content_draft.dart';

/// レッスン・クイズの下書きを編集する部品(AI生成の確認・手作業の作成で共通)。
/// [allowAddRemove]がtrueなら、レッスン・問題の追加と削除ができる。
class DraftEditor extends StatefulWidget {
  final GeneratedContentDraft draft;

  /// 新規モジュールの作成・編集のとき、タイトルと説明の入力欄を出す。
  final bool showModuleFields;
  final bool allowAddRemove;

  const DraftEditor({
    super.key,
    required this.draft,
    required this.showModuleFields,
    this.allowAddRemove = false,
  });

  @override
  State<DraftEditor> createState() => _DraftEditorState();
}

class _DraftEditorState extends State<DraftEditor> {
  // 項目を削除したとき、入力欄の初期値が前の項目のまま残らないよう、作り直すための番号。
  int _version = 0;

  GeneratedContentDraft get draft => widget.draft;

  void _rebuildAll(VoidCallback change) => setState(() {
        change();
        _version++;
      });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    return KeyedSubtree(
      key: ValueKey(_version),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showModuleFields) ...[
            TextFormField(
              key: const ValueKey('module_title'),
              initialValue: draft.moduleTitle,
              decoration: const InputDecoration(labelText: 'モジュールタイトル'),
              onChanged: (v) => draft.moduleTitle = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const ValueKey('module_description'),
              initialValue: draft.moduleDescription,
              decoration: const InputDecoration(labelText: 'モジュールの説明'),
              maxLines: 2,
              onChanged: (v) => draft.moduleDescription = v,
            ),
            const SizedBox(height: 20),
          ],
          Text('レッスン(${draft.lessons.length}本)', style: titleStyle),
          for (var i = 0; i < draft.lessons.length; i++)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('lesson_title_$i'),
                            initialValue: draft.lessons[i].title,
                            decoration: InputDecoration(labelText: 'レッスン${i + 1} タイトル'),
                            onChanged: (v) => draft.lessons[i].title = v,
                          ),
                        ),
                        if (widget.allowAddRemove)
                          IconButton(
                            key: ValueKey('lesson_remove_$i'),
                            tooltip: 'このレッスンを削除',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _rebuildAll(() => draft.lessons.removeAt(i)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: ValueKey('lesson_body_$i'),
                      initialValue: draft.lessons[i].body,
                      decoration: const InputDecoration(labelText: '本文'),
                      maxLines: 5,
                      onChanged: (v) => draft.lessons[i].body = v,
                    ),
                  ],
                ),
              ),
            ),
          if (widget.allowAddRemove)
            TextButton.icon(
              key: const ValueKey('lesson_add'),
              onPressed: () => setState(() => draft.lessons.add(DraftLesson.blank())),
              icon: const Icon(Icons.add),
              label: const Text('レッスンを追加'),
            ),
          const SizedBox(height: 12),
          Text('クイズ(${draft.quizQuestions.length}問)', style: titleStyle),
          for (var i = 0; i < draft.quizQuestions.length; i++)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: ValueKey('quiz_question_$i'),
                            initialValue: draft.quizQuestions[i].question,
                            decoration: InputDecoration(labelText: '問題${i + 1}'),
                            maxLines: null,
                            onChanged: (v) => draft.quizQuestions[i].question = v,
                          ),
                        ),
                        if (widget.allowAddRemove)
                          IconButton(
                            key: ValueKey('quiz_remove_$i'),
                            tooltip: 'この問題を削除',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _rebuildAll(() => draft.quizQuestions.removeAt(i)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RadioGroup<int>(
                      groupValue: draft.quizQuestions[i].correctIndex,
                      onChanged: (v) => setState(() => draft.quizQuestions[i].correctIndex = v!),
                      child: Column(
                        children: [
                          for (var c = 0; c < draft.quizQuestions[i].choices.length; c++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Radio<int>(value: c),
                                  Expanded(
                                    child: TextFormField(
                                      key: ValueKey('quiz_choice_${i}_$c'),
                                      initialValue: draft.quizQuestions[i].choices[c],
                                      decoration: InputDecoration(labelText: '選択肢${c + 1}'),
                                      onChanged: (v) => draft.quizQuestions[i].choices[c] = v,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.allowAddRemove)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 4),
                        child: Text('正解の選択肢を、左の丸で選んでください', style: Theme.of(context).textTheme.bodySmall),
                      ),
                    TextFormField(
                      key: ValueKey('quiz_explanation_$i'),
                      initialValue: draft.quizQuestions[i].explanation,
                      decoration: const InputDecoration(labelText: '解説'),
                      maxLines: 2,
                      onChanged: (v) => draft.quizQuestions[i].explanation = v,
                    ),
                  ],
                ),
              ),
            ),
          if (widget.allowAddRemove)
            TextButton.icon(
              key: const ValueKey('quiz_add'),
              onPressed: () => setState(() => draft.quizQuestions.add(DraftQuizQuestion.blank())),
              icon: const Icon(Icons.add),
              label: const Text('問題を追加'),
            ),
        ],
      ),
    );
  }
}
