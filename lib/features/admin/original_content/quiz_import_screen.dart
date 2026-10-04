import 'package:flutter/material.dart';
import '../../../core/quiz_import.dart';
import '../../../data/models/generated_content_draft.dart';

/// 問題の表(Excelからコピー)を貼り付けて、確認してから取り込む画面。
/// 取り込む問題は、呼び出し元の下書きに追加される(この画面では保存しない)。
class QuizImportScreen extends StatefulWidget {
  const QuizImportScreen({super.key});

  @override
  State<QuizImportScreen> createState() => _QuizImportScreenState();
}

class _QuizImportScreenState extends State<QuizImportScreen> {
  final _controller = TextEditingController();
  QuizParseResult? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('問題を表から取り込む')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Excelなどの表をコピーして、下に貼り付けてください(カンマ区切りも使えます)。'),
          const SizedBox(height: 8),
          Text(
            '1行に1問。列の順番は「問題 / 選択肢1 / 選択肢2 / 選択肢3 / 選択肢4 / 正解 / 解説」です。'
            '正解は、選択肢の番号(1〜4)か、選択肢の文で指定します。選択肢は2つ以上が必要で、解説は省略できます。'
            '1行目が「問題」から始まる見出しなら、読み飛ばします。',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('import_text'),
            controller: _controller,
            minLines: 6,
            maxLines: 14,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'USBメモリの扱いで正しいのは?\t許可済みの端末のみ使う\t私物を使う\t\t\t1\t私物は持ち込まない',
            ),
            onChanged: (_) => setState(() => _result = null),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              key: const ValueKey('import_check'),
              onPressed: _controller.text.trim().isEmpty
                  ? null
                  : () => setState(() => _result = QuizImport.parse(_controller.text)),
              child: const Text('内容を確認する'),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 12),
            if (result.errors.isNotEmpty)
              Container(
                key: const ValueKey('import_errors'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('取り込めません。次を直してください',
                        style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                    for (final e in result.errors.take(10)) Text(e),
                    if (result.errors.length > 10) Text('ほか${result.errors.length - 10}件'),
                  ],
                ),
              )
            else ...[
              Text('${result.questions.length}問を取り込めます', style: const TextStyle(fontWeight: FontWeight.bold)),
              for (final q in result.questions.take(3)) Text('・${q.question}'),
              if (result.questions.length > 3) Text('ほか${result.questions.length - 3}問'),
              const SizedBox(height: 8),
              FilledButton(
                key: const ValueKey('import_apply'),
                onPressed: () => Navigator.of(context).pop<List<DraftQuizQuestion>>(result.questions),
                child: Text('${result.questions.length}問を追加する'),
              ),
              const SizedBox(height: 4),
              Text('追加したあと、編集画面で内容を直してから保存できます。', style: theme.textTheme.bodySmall),
            ],
          ],
        ],
      ),
    );
  }
}
