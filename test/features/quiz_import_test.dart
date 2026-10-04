import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/quiz_import.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/features/admin/original_content/manual_content_editor_screen.dart';
import 'package:safy/providers/firebase_providers.dart';
import 'package:safy/providers/session_provider.dart';

class _Session extends SessionNotifier {
  _Session() {
    state = SessionState(
      employee: Employee(
        id: 'admin',
        companyId: 'c1',
        teamId: 't',
        displayName: '管理者',
        role: EmployeeRole.admin,
        createdAt: DateTime(2026, 1, 1),
      ),
      company: Company(
        id: 'c1',
        name: 'テスト',
        industryId: 'retail',
        planType: PlanType.trial,
        contractedHeadcount: 5,
        customPassThreshold: const {},
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }
}

void main() {
  group('QuizImport', () {
    test('タブ区切り(Excel)・見出し行・番号と文での正解・解説の省略', () {
      final r = QuizImport.parse(
        '問題\t選択肢1\t選択肢2\t選択肢3\t選択肢4\t正解\t解説\n'
        'Q1\t甲\t乙\t\t\t2\t乙が正しい\n'
        'Q2\tA\tB\tC\tD\tC\t\n',
      );
      expect(r.errors, isEmpty);
      expect(r.questions.length, 2);
      expect(r.questions[0].correctIndex, 1);
      expect(r.questions[0].choices, ['甲', '乙', '', '']);
      expect(r.questions[0].explanation, '乙が正しい');
      expect(r.questions[1].correctIndex, 2); // 文で指定
      expect(r.questions[1].explanation, '');
    });

    test('カンマ区切りと、引用符の中のカンマ・改行', () {
      final r = QuizImport.parse('"問題1, その1","a","b",,,1,"解説\n2行目"');
      expect(r.errors, isEmpty);
      expect(r.questions.single.question, '問題1, その1');
      expect(r.questions.single.explanation, '解説\n2行目');
    });

    test('エラーは行番号つきで、1件でもあれば1問も取り込まない', () {
      final r = QuizImport.parse(
        '\t甲\t乙\t\t\t1\n' // 問題文なし
        'Q2\t甲\t\t\t\t1\n' // 選択肢が1つ
        'Q3\t甲\t乙\t\t\t3\n' // 正解が空の選択肢
        'Q4\t甲\t乙\t\t\t丙\n' // 正解の文が選択肢にない
        'Q5\t甲\t乙\t\t\t\n' // 正解なし
        'Q6\t甲\t乙\t\t\t1\n', // これは正しい
      );
      expect(r.questions, isEmpty);
      expect(r.errors, [
        '1行目: 問題文がありません',
        '2行目: 選択肢を2つ以上入力してください',
        '3行目: 正解は、入力済みの選択肢の番号(1〜4)か、選択肢の文で指定してください',
        '4行目: 正解は、入力済みの選択肢の番号(1〜4)か、選択肢の文で指定してください',
        '5行目: 正解は、入力済みの選択肢の番号(1〜4)か、選択肢の文で指定してください',
      ]);
    });

    test('空と上限超過', () {
      expect(QuizImport.parse('  \n').errors, isNotEmpty);
      final many = List.generate(101, (i) => 'Q$i\ta\tb\t\t\t1').join('\n');
      final r = QuizImport.parse(many);
      expect(r.questions, isEmpty);
      expect(r.errors.single, contains('100問まで'));
    });
  });

  testWidgets('編集画面から表を取り込むと、問題が追加され、保存できる', (tester) async {
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = FakeFirebaseFirestore();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(db),
        sessionProvider.overrideWith((ref) => _Session()),
      ],
      child: const MaterialApp(home: ManualContentEditorScreen.create()),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('module_title')), '取り込みテスト');
    await tester.tap(find.byKey(const ValueKey('import_open')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('import_text')), 'Q1\t甲\t乙\t\t\t2\t解説1\nQ2\t丙\t丁\t\t\t1\t');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('import_check')));
    await tester.pump();
    expect(find.text('2問を取り込めます'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('import_apply')));
    await tester.pumpAndSettle();

    expect(find.text('クイズ(2問)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('save')));
    await tester.pumpAndSettle();

    final module = (await db.collection('companies/c1/customModules').get()).docs.single;
    final qs = await db.collection('companies/c1/customModules/${module.id}/quizQuestions').get();
    expect(qs.docs.length, 2);
    final q1 = qs.docs.firstWhere((d) => d.data()['question'] == 'Q1').data();
    expect(q1['choices'], ['甲', '乙']);
    expect(q1['correctIndex'], 1);
  });

  testWidgets('取り込みに誤りがあると、理由を表示して追加できない', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        sessionProvider.overrideWith((ref) => _Session()),
      ],
      child: const MaterialApp(home: ManualContentEditorScreen.create()),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('import_open')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('import_text')), 'Q1\t甲\t乙\t\t\t9');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('import_check')));
    await tester.pump();
    expect(find.byKey(const ValueKey('import_errors')), findsOneWidget);
    expect(find.byKey(const ValueKey('import_apply')), findsNothing);
  });
}
