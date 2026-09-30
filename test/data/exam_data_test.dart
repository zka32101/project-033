import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final file in const ['tier2-exam.json', 'tier3-exam.json']) {
    test('$file: 設問の形式(選択肢4つ・正解の範囲・ID重複なし・分野あり)が正しい', () {
      final data = jsonDecode(File('functions/training/$file').readAsStringSync())
          as Map<String, dynamic>;
      final questions = (data['questions'] as List).cast<Map<String, dynamic>>();
      expect(questions.length, data['questions'].length);
      expect(questions.length >= 20, isTrue);
      expect(questions.map((q) => q['id']).toSet().length, questions.length);
      expect(questions.map((q) => q['order']).toSet().length, questions.length);
      for (final q in questions) {
        final options = (q['options'] as List).cast<String>();
        expect(options.length, 4, reason: '${q['id']}');
        expect(options.toSet().length, 4, reason: '${q['id']}: 選択肢の重複');
        final correct = q['correctOption'] as int;
        expect(correct >= 0 && correct < 4, isTrue, reason: '${q['id']}');
        expect((q['text'] as String).isNotEmpty, isTrue);
        expect((q['category'] as String).isNotEmpty && q['category'] != '未分類', isTrue);
      }
      // 正解位置が極端に偏っていない(当てずっぽうで高得点を取れない)
      final counts = List.filled(4, 0);
      for (final q in questions) {
        counts[q['correctOption'] as int]++;
      }
      for (final c in counts) {
        expect(c / questions.length < 0.35, isTrue, reason: '正解位置の偏り: $counts');
      }
    });
  }
}
