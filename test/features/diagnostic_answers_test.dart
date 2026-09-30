import 'package:flutter_test/flutter_test.dart';
import 'package:safy/features/learning_path/diagnostic_recommendation.dart';

void main() {
  test('診断の回答は文字列キーで保存されても、読み戻すと数値キーに復元できる', () {
    final sent = {for (final e in {0: 2, 1: 3, 2: 1}.entries) e.key.toString(): e.value};
    expect(sent.keys.every((k) => k is String), isTrue);
    expect(normalizeDiagnosticAnswers(sent), {0: 2, 1: 3, 2: 1});
  });
}
