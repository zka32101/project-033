import 'package:csv/csv.dart';
import '../data/models/generated_content_draft.dart';

class QuizParseResult {
  final List<DraftQuizQuestion> questions;

  /// 行番号つきのエラー。1件でもあれば取り込まない。
  final List<String> errors;

  const QuizParseResult(this.questions, this.errors);
}

/// 貼り付けられた問題の表(Excelからのコピー=タブ区切り、またはCSV)を読み取る。
/// 列: 問題 / 選択肢1 / 選択肢2 / 選択肢3 / 選択肢4 / 正解 / 解説(任意)。
/// 正解は、選択肢の番号(1〜4)でも、選択肢の文そのものでも指定できる。
/// 1行目が見出し(「問題」「問題文」)なら読み飛ばす。
class QuizImport {
  const QuizImport._();

  static const maxQuestions = 100;

  static QuizParseResult parse(String text) {
    // 先頭のタブは「問題の列が空」を意味するので、trim()では消さず、前後の改行だけを取り除く。
    final body = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'^\n+|\n+$'), '');
    if (body.trim().isEmpty) return const QuizParseResult([], ['取り込む行がありません']);

    final delimiter = body.contains('\t') ? '\t' : ',';
    final rows = CsvToListConverter(
      fieldDelimiter: delimiter,
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(body).where((r) => r.any((c) => c.toString().trim().isNotEmpty)).toList();
    if (rows.isNotEmpty) {
      final first = rows.first.first.toString().trim();
      if (first == '問題' || first == '問題文') rows.removeAt(0);
    }
    if (rows.isEmpty) return const QuizParseResult([], ['取り込む行がありません']);
    if (rows.length > maxQuestions) {
      return QuizParseResult(const [], ['一度に取り込めるのは$maxQuestions問までです(${rows.length}行)']);
    }

    final errors = <String>[];
    final questions = <DraftQuizQuestion>[];
    for (var i = 0; i < rows.length; i++) {
      final n = i + 1;
      final cells = [for (final c in rows[i]) c.toString().trim()];
      String cell(int idx) => idx < cells.length ? cells[idx] : '';
      final question = cell(0);
      if (question.isEmpty) {
        errors.add('$n行目: 問題文がありません');
        continue;
      }
      final choices = [for (var c = 1; c <= 4; c++) cell(c)];
      final filled = choices.where((c) => c.isNotEmpty).length;
      if (filled < ContentDraftValidator.minChoices) {
        errors.add('$n行目: 選択肢を${ContentDraftValidator.minChoices}つ以上入力してください');
        continue;
      }
      final correct = _correctIndex(cell(5), choices);
      if (correct == null) {
        errors.add('$n行目: 正解は、入力済みの選択肢の番号(1〜4)か、選択肢の文で指定してください');
        continue;
      }
      questions.add(DraftQuizQuestion(
        question: question,
        choices: choices,
        correctIndex: correct,
        explanation: cell(6),
      ));
    }
    return QuizParseResult(errors.isEmpty ? questions : const [], errors);
  }

  static int? _correctIndex(String value, List<String> choices) {
    if (value.isEmpty) return null;
    final number = int.tryParse(value);
    if (number != null) {
      final idx = number - 1;
      return idx >= 0 && idx < choices.length && choices[idx].isNotEmpty ? idx : null;
    }
    final idx = choices.indexOf(value);
    return idx >= 0 && choices[idx].isNotEmpty ? idx : null;
  }
}
