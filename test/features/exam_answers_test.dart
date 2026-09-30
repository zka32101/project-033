import 'package:flutter_test/flutter_test.dart';
import 'package:safy/features/exam/live_exam_screen.dart';

void main() {
  test('試験の回答は文字列キーのMapにして送る(数値キーだと送信に失敗するため)', () {
    final result = serializeExamAnswers({0: 'option_1a', 3: 'option_0a'});
    expect(result, {'0': 'option_1a', '3': 'option_0a'});
    expect(result.keys.every((k) => k is String), isTrue);
    expect(serializeExamAnswers({}), isEmpty);
  });
}
