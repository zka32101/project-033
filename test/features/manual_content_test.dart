import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/category_model.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/data/models/generated_content_draft.dart';
import 'package:safy/data/models/industry_model.dart';
import 'package:safy/data/models/module_model.dart';
import 'package:safy/features/admin/original_content/manual_content_editor_screen.dart';
import 'package:safy/providers/firebase_providers.dart';
import 'package:safy/providers/session_provider.dart';
import 'package:safy/services/content_service.dart';
import 'package:safy/services/custom_content_service.dart';

Employee _admin() => Employee(
      id: 'admin',
      companyId: 'c1',
      teamId: 't',
      displayName: '管理者',
      role: EmployeeRole.admin,
      createdAt: DateTime(2026, 1, 1),
    );

Company _company() => Company(
      id: 'c1',
      name: 'テスト',
      industryId: 'retail',
      planType: PlanType.trial,
      contractedHeadcount: 5,
      customPassThreshold: const {},
      createdAt: DateTime(2026, 1, 1),
    );

class _Session extends SessionNotifier {
  _Session() {
    state = SessionState(employee: _admin(), company: _company());
  }
}

GeneratedContentDraft _draft({
  String? title = 'テスト研修',
  List<DraftLesson>? lessons,
  List<DraftQuizQuestion>? questions,
}) =>
    GeneratedContentDraft(
      moduleTitle: title,
      moduleDescription: '説明',
      lessons: lessons ?? [DraftLesson(title: 'L1', body: '本文1')],
      quizQuestions: questions ??
          [
            DraftQuizQuestion(question: 'Q1', choices: ['a', 'b', '', ''], correctIndex: 1, explanation: '解説'),
          ],
    );

void main() {
  group('ContentDraftValidator', () {
    test('正しい下書きは問題なし', () {
      expect(ContentDraftValidator.validate(_draft(), requireModuleTitle: true), isEmpty);
    });

    test('タイトル・中身・問題文・選択肢・正解を検証する', () {
      expect(ContentDraftValidator.validate(_draft(title: ' '), requireModuleTitle: true), ['研修のタイトルを入力してください']);
      expect(ContentDraftValidator.validate(_draft(title: ' '), requireModuleTitle: false), isEmpty);
      expect(
        ContentDraftValidator.validate(_draft(lessons: [], questions: []), requireModuleTitle: false),
        ['レッスンまたは問題を1つ以上追加してください'],
      );
      expect(
        ContentDraftValidator.validate(_draft(lessons: [DraftLesson(title: '', body: 'x')]), requireModuleTitle: false),
        ['レッスン1: タイトルと本文を入力してください'],
      );
      final errs = ContentDraftValidator.validate(
        _draft(questions: [
          DraftQuizQuestion(question: '', choices: ['a', 'b', '', ''], correctIndex: 0, explanation: ''),
          DraftQuizQuestion(question: 'Q', choices: ['a', '', '', ''], correctIndex: 0, explanation: ''),
          DraftQuizQuestion(question: 'Q', choices: ['a', 'b', '', ''], correctIndex: 3, explanation: ''),
        ]),
        requireModuleTitle: false,
      );
      expect(errs, [
        '問題1: 問題文を入力してください',
        '問題2: 選択肢を2つ以上入力してください',
        '問題3: 正解に、入力済みの選択肢を選んでください',
      ]);
    });

    test('整形: 空の選択肢を詰め、正解の位置を合わせる', () {
      final d = _draft(questions: [
        DraftQuizQuestion(question: ' Q ', choices: ['', 'x', '', 'y'], correctIndex: 3, explanation: ' e '),
      ]);
      ContentDraftValidator.normalize(d);
      expect(d.quizQuestions.single.choices, ['x', 'y']);
      expect(d.quizQuestions.single.correctIndex, 1);
      expect(d.quizQuestions.single.question, 'Q');
      expect(d.quizQuestions.single.explanation, 'e');
    });
  });

  group('CustomContentService(手作業)', () {
    late FakeFirebaseFirestore db;
    late CustomContentService service;

    setUp(() {
      db = FakeFirebaseFirestore();
      service = CustomContentService(db);
    });

    test('作成→編集(IDを保って更新・削除分は消える)→削除', () async {
      final d = _draft(lessons: [
        DraftLesson(title: 'L1', body: 'b1'),
        DraftLesson(title: 'L2', body: 'b2'),
      ]);
      ContentDraftValidator.normalize(d);
      final module = await service.saveManualModule(
        companyId: 'c1',
        categoryId: CategoryId.infoMorals,
        createdByEmployeeId: 'admin',
        draft: d,
      );
      expect(module.sourceTheme, '手動作成');

      final loaded = await service.loadCustomModuleDraft(module);
      expect(loaded.lessons.map((l) => l.title), ['L1', 'L2']);
      expect(loaded.quizQuestions.single.choices, ['a', 'b', '', '']); // 編集画面用に4つへ
      final firstLessonId = loaded.lessons.first.id;

      // 2つ目のレッスンを消し、1つ目を書き換え、問題を1つ追加
      loaded.lessons.removeAt(1);
      loaded.lessons.first.title = 'L1改';
      loaded.quizQuestions.add(DraftQuizQuestion(question: 'Q2', choices: ['x', 'y', '', ''], correctIndex: 0, explanation: ''));
      loaded.moduleTitle = '改題';
      ContentDraftValidator.normalize(loaded);
      await service.saveManualModule(
        companyId: 'c1',
        existing: module,
        categoryId: CategoryId.infoMorals,
        createdByEmployeeId: 'admin',
        draft: loaded,
      );

      final modules = await service.listCustomModules('c1');
      expect(modules.single.title, '改題');
      expect(modules.single.id, module.id);
      final lessons = await service.listCustomModuleLessons('c1', module.id);
      expect(lessons.map((l) => l.title), ['L1改']);
      expect(lessons.single.id, firstLessonId);
      expect((await service.listCustomModuleQuizQuestions('c1', module.id)).length, 2);

      await service.deleteCustomModule('c1', module.id);
      expect(await service.listCustomModules('c1'), isEmpty);
      expect(await service.listCustomModuleLessons('c1', module.id), isEmpty);
      expect(await service.listCustomModuleQuizQuestions('c1', module.id), isEmpty);
    });

    test('既存研修への追加: 保存→編集→空にすると追加分ごと削除', () async {
      final d = _draft(title: null);
      ContentDraftValidator.normalize(d);
      await service.saveManualExtension(companyId: 'c1', targetModuleId: 'm1', draft: d);
      expect(await service.listExtendedModuleIds('c1'), {'m1'});

      final loaded = await service.loadExtensionDraft('c1', 'm1');
      expect(loaded.lessons.single.title, 'L1');
      expect(loaded.quizQuestions.single.question, 'Q1');

      loaded.quizQuestions.clear();
      loaded.lessons.clear();
      await service.saveManualExtension(companyId: 'c1', targetModuleId: 'm1', draft: loaded);
      expect(await service.listExtendedModuleIds('c1'), isEmpty);
      expect(await service.listModuleExtensionLessons('c1', 'm1'), isEmpty);
    });

    test('他社のオリジナル研修は混ざらない', () async {
      final d = _draft();
      ContentDraftValidator.normalize(d);
      await service.saveManualModule(companyId: 'c1', categoryId: CategoryId.infoMorals, createdByEmployeeId: 'a', draft: d);
      expect(await service.listCustomModules('c2'), isEmpty);
    });
  });

  group('ContentService: オリジナル研修の合流', () {
    test('companyIdを渡すと自社のオリジナル研修が一覧に入り、渡さなければ入らない', () async {
      final db = FakeFirebaseFirestore();
      await db.doc('modules/g1').set(const Module(
            id: 'g1',
            categoryId: CategoryId.infoMorals,
            title: '既存',
            description: '',
            passThresholdDefault: 80,
            isFreeTrial: false,
            sortOrder: 1,
          ).toMap());
      final d = _draft();
      ContentDraftValidator.normalize(d);
      final custom = await CustomContentService(db)
          .saveManualModule(companyId: 'c1', categoryId: CategoryId.infoMorals, createdByEmployeeId: 'a', draft: d);
      const industry = Industry(
        id: 'retail',
        name: '小売',
        highPriority: [CategoryId.infoMorals],
        midPriority: [],
        lowPriority: [],
      );
      final content = ContentService(db);
      expect((await content.listModulesForIndustry(industry)).map((m) => m.id), ['g1']);
      final merged = await content.listModulesForIndustry(industry, companyId: 'c1');
      expect(merged.map((m) => m.id).toSet(), {'g1', custom.id});
      expect(merged.firstWhere((m) => m.id == custom.id).isCustom, isTrue);
      expect((await content.listModulesForIndustry(industry, companyId: 'c2')).map((m) => m.id), ['g1']);
    });
  });

  group('ManualContentEditorScreen', () {
    Future<FakeFirebaseFirestore> pump(WidgetTester tester, Widget screen) async {
      tester.view.physicalSize = const Size(900, 3200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = FakeFirebaseFirestore();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          firestoreProvider.overrideWithValue(db),
          sessionProvider.overrideWith((ref) => _Session()),
        ],
        child: MaterialApp(home: screen),
      ));
      await tester.pumpAndSettle();
      return db;
    }

    testWidgets('新しい研修を作る: 入力→保存でFirestoreに保存される', (tester) async {
      final db = await pump(tester, const ManualContentEditorScreen.create());

      await tester.enterText(find.byKey(const ValueKey('module_title')), '自社の情報セキュリティ');
      await tester.tap(find.byKey(const ValueKey('lesson_add')));
      await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('lesson_title_0')), 'ルール');
      await tester.enterText(find.byKey(const ValueKey('lesson_body_0')), '社外にデータを持ち出さない');
      await tester.tap(find.byKey(const ValueKey('quiz_add')));
      await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('quiz_question_0')), '持ち出してよいのは?');
      await tester.enterText(find.byKey(const ValueKey('quiz_choice_0_0')), '許可済みの端末');
      await tester.enterText(find.byKey(const ValueKey('quiz_choice_0_1')), '私物のUSB');
      await tester.tap(find.byType(Radio<int>).first); // 正解=選択肢1
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('save')));
      await tester.pumpAndSettle();

      final modules = await db.collection('companies/c1/customModules').get();
      expect(modules.docs.single.data()['title'], '自社の情報セキュリティ');
      final id = modules.docs.single.id;
      final lessons = await db.collection('companies/c1/customModules/$id/lessons').get();
      expect(lessons.docs.single.data()['body'], '社外にデータを持ち出さない');
      final qs = await db.collection('companies/c1/customModules/$id/quizQuestions').get();
      expect(qs.docs.single.data()['choices'], ['許可済みの端末', '私物のUSB']);
      expect(qs.docs.single.data()['correctIndex'], 0);
    });

    testWidgets('入力が足りないと保存せず、理由を表示する', (tester) async {
      final db = await pump(tester, const ManualContentEditorScreen.create());
      await tester.tap(find.byKey(const ValueKey('save')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('errors')), findsOneWidget);
      expect(find.text('研修のタイトルを入力してください'), findsOneWidget);
      expect((await db.collection('companies/c1/customModules').get()).docs, isEmpty);
    });

    testWidgets('問題を削除すると、残った問題の入力欄が正しく並び直る', (tester) async {
      await pump(tester, const ManualContentEditorScreen.create());
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const ValueKey('quiz_add')));
        await tester.pump();
      }
      await tester.enterText(find.byKey(const ValueKey('quiz_question_0')), '1つ目');
      await tester.enterText(find.byKey(const ValueKey('quiz_question_1')), '2つ目');
      await tester.tap(find.byKey(const ValueKey('quiz_remove_0')));
      await tester.pumpAndSettle();
      expect(find.text('クイズ(1問)'), findsOneWidget);
      expect(find.text('2つ目'), findsOneWidget);
      expect(find.text('1つ目'), findsNothing);
    });
  });
}
