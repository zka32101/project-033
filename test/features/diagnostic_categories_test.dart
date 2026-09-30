import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/category_model.dart';
import 'package:safy/features/learning_path/diagnostic_recommendation.dart';

void main() {
  test('診断の分野は、Safyの9分野と一致する', () {
    expect(kDiagnosticQuestionCategories.length, 9);
    final ids = kDiagnosticQuestionCategories.map((c) => c.categoryId).toSet();
    expect(ids, CategoryId.values.map((c) => c.name).toSet());
    for (final c in kDiagnosticQuestionCategories) {
      expect(kWeakCategoryReasons.containsKey(c.label), isTrue, reason: c.label);
    }
    final names = Category.all.map((c) => c.name).toSet();
    for (final c in kDiagnosticQuestionCategories) {
      expect(names.contains(c.label), isTrue, reason: '${c.label} はアプリの分野名と一致する必要がある');
    }
  });

  test('回答が低い分野が弱点になり、その分野のモジュールが優先して推薦される', () {
    // 0番目(情報モラル)とセキュリティ(1番目)が低く、ほかは高い
    final weak = determineWeakCategories({
      for (var i = 0; i < 9; i++) i: i <= 1 ? 0 : 3,
    });
    expect(weak, ['情報モラル', 'セキュリティ']);

    final recs = buildModuleRecommendations(
      modules: [
        {'id': 'a', 'title': 'その他', 'categoryId': 'bcp', 'description': ''},
        {'id': 'b', 'title': '端末の管理', 'categoryId': 'security', 'description': ''},
      ],
      weakCategories: weak,
      progressByModuleId: const {},
    );
    expect(recs.first.module['id'], 'b');
    expect(recs.first.reason.contains('セキュリティ'), isTrue);
  });
}
