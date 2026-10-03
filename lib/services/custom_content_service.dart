import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/category_model.dart';
import '../data/models/custom_module_model.dart';
import '../data/models/generated_content_draft.dart';
import '../data/models/lesson_model.dart';
import '../data/models/quiz_question_model.dart';
import 'firestore_paths.dart';

/// オリジナルコンテンツ(プレミアムプラン)のFirestore保存・取得。
/// AI生成(ContentGenerationService)はドラフトを返すだけで保存しない。
/// 管理者が画面上で確認・編集した内容をここで初めてFirestoreへ書き込む。
class CustomContentService {
  final FirebaseFirestore _db;
  CustomContentService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  /// 新規オリジナルモジュール一式を保存する(要moduleCreationプラン。権限確認はFirestoreルール側)。
  Future<CustomModule> saveNewModule({
    required String companyId,
    required CategoryId categoryId,
    required String theme,
    required String createdByEmployeeId,
    required GeneratedContentDraft draft,
    int sortOrder = 0,
    int passThresholdDefault = 80,
  }) async {
    final moduleRef = _db.collection(FirestorePaths.customModules(companyId)).doc();
    final module = CustomModule(
      id: moduleRef.id,
      companyId: companyId,
      categoryId: categoryId,
      title: draft.moduleTitle ?? '',
      description: draft.moduleDescription ?? '',
      passThresholdDefault: passThresholdDefault,
      sortOrder: sortOrder,
      createdByEmployeeId: createdByEmployeeId,
      sourceTheme: theme,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();
    batch.set(moduleRef, module.toMap());

    final lessonsCollection =
        _db.collection(FirestorePaths.customModuleLessons(companyId, moduleRef.id));
    for (var i = 0; i < draft.lessons.length; i++) {
      final l = draft.lessons[i];
      final ref = lessonsCollection.doc();
      batch.set(
        ref,
        Lesson(
          id: ref.id,
          moduleId: moduleRef.id,
          title: l.title,
          body: l.body,
          imageUrls: const [],
          sortOrder: i + 1,
        ).toMap(),
      );
    }

    final quizCollection =
        _db.collection(FirestorePaths.customModuleQuizQuestions(companyId, moduleRef.id));
    for (final q in draft.quizQuestions) {
      final ref = quizCollection.doc();
      batch.set(
        ref,
        QuizQuestion(
          id: ref.id,
          moduleId: moduleRef.id,
          question: q.question,
          choices: q.choices,
          correctIndex: q.correctIndex,
          explanation: q.explanation,
        ).toMap(),
      );
    }

    await batch.commit();
    return module;
  }

  /// 既存(グローバル)モジュールへ追加するレッスン+クイズを保存する(要moduleExtension以上)。
  Future<void> saveModuleExtension({
    required String companyId,
    required String targetModuleId,
    required String theme,
    required GeneratedContentDraft draft,
  }) async {
    final extensionRef = _db.doc(FirestorePaths.moduleExtension(companyId, targetModuleId));
    final batch = _db.batch();
    batch.set(extensionRef, {
      'moduleId': targetModuleId,
      'lastTheme': theme,
      'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));

    final lessonsCollection =
        _db.collection(FirestorePaths.moduleExtensionLessons(companyId, targetModuleId));
    for (final l in draft.lessons) {
      final ref = lessonsCollection.doc();
      batch.set(
        ref,
        Lesson(
          id: ref.id,
          moduleId: targetModuleId,
          title: l.title,
          body: l.body,
          imageUrls: const [],
          // 既存レッスンの後ろに追加されるよう大きめのsortOrderにする
          sortOrder: 1000 + ref.id.hashCode.abs() % 1000,
        ).toMap(),
      );
    }

    final quizCollection =
        _db.collection(FirestorePaths.moduleExtensionQuizQuestions(companyId, targetModuleId));
    for (final q in draft.quizQuestions) {
      final ref = quizCollection.doc();
      batch.set(
        ref,
        QuizQuestion(
          id: ref.id,
          moduleId: targetModuleId,
          question: q.question,
          choices: q.choices,
          correctIndex: q.correctIndex,
          explanation: q.explanation,
        ).toMap(),
      );
    }

    await batch.commit();
  }

  // --- 手作業での作成・編集(AIなし。管理者なら契約にかかわらず利用できる) ---

  /// 保存済みの子ドキュメント(レッスン/問題)を、下書きの内容に合わせて作成・更新・削除する。
  /// 下書きに残っているIDは更新、IDなしは新規、下書きにないIDは削除。
  Future<void> _syncChildren({
    required WriteBatch batch,
    required CollectionReference<Map<String, dynamic>> collection,
    required List<({String? id, Map<String, dynamic> Function(String id) data})> items,
  }) async {
    final existing = await collection.get();
    final keep = <String>{};
    for (final item in items) {
      final ref = item.id != null ? collection.doc(item.id) : collection.doc();
      keep.add(ref.id);
      batch.set(ref, item.data(ref.id));
    }
    for (final d in existing.docs) {
      if (!keep.contains(d.id)) batch.delete(d.reference);
    }
  }

  List<({String? id, Map<String, dynamic> Function(String id) data})> _lessonItems(
    String moduleId,
    GeneratedContentDraft draft, {
    int sortBase = 0,
  }) =>
      [
        for (var i = 0; i < draft.lessons.length; i++)
          (
            id: draft.lessons[i].id,
            data: (String id) => Lesson(
                  id: id,
                  moduleId: moduleId,
                  title: draft.lessons[i].title,
                  body: draft.lessons[i].body,
                  imageUrls: const [],
                  sortOrder: sortBase + i + 1,
                ).toMap(),
          ),
      ];

  List<({String? id, Map<String, dynamic> Function(String id) data})> _questionItems(
    String moduleId,
    GeneratedContentDraft draft,
  ) =>
      [
        for (final q in draft.quizQuestions)
          (
            id: q.id,
            data: (String id) => QuizQuestion(
                  id: id,
                  moduleId: moduleId,
                  question: q.question,
                  choices: q.choices,
                  correctIndex: q.correctIndex,
                  explanation: q.explanation,
                ).toMap(),
          ),
      ];

  /// 手で作った(または編集した)オリジナル研修を保存する。module が既存なら更新、なければ新規作成。
  Future<CustomModule> saveManualModule({
    required String companyId,
    CustomModule? existing,
    required CategoryId categoryId,
    required String createdByEmployeeId,
    required GeneratedContentDraft draft,
    int passThresholdDefault = 80,
  }) async {
    final moduleRef = existing != null
        ? _db.doc(FirestorePaths.customModule(companyId, existing.id))
        : _db.collection(FirestorePaths.customModules(companyId)).doc();
    final module = CustomModule(
      id: moduleRef.id,
      companyId: companyId,
      categoryId: categoryId,
      title: draft.moduleTitle ?? '',
      description: draft.moduleDescription ?? '',
      passThresholdDefault: existing?.passThresholdDefault ?? passThresholdDefault,
      sortOrder: existing?.sortOrder ?? 0,
      createdByEmployeeId: existing?.createdByEmployeeId ?? createdByEmployeeId,
      sourceTheme: existing?.sourceTheme ?? '手動作成',
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    final batch = _db.batch();
    batch.set(moduleRef, module.toMap());
    await _syncChildren(
      batch: batch,
      collection: _db.collection(FirestorePaths.customModuleLessons(companyId, moduleRef.id)),
      items: _lessonItems(moduleRef.id, draft),
    );
    await _syncChildren(
      batch: batch,
      collection: _db.collection(FirestorePaths.customModuleQuizQuestions(companyId, moduleRef.id)),
      items: _questionItems(moduleRef.id, draft),
    );
    await batch.commit();
    return module;
  }

  /// オリジナル研修を、レッスン・問題ごと削除する。
  Future<void> deleteCustomModule(String companyId, String moduleId) async {
    final batch = _db.batch();
    for (final path in [
      FirestorePaths.customModuleLessons(companyId, moduleId),
      FirestorePaths.customModuleQuizQuestions(companyId, moduleId),
    ]) {
      final snap = await _db.collection(path).get();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
    }
    batch.delete(_db.doc(FirestorePaths.customModule(companyId, moduleId)));
    await batch.commit();
  }

  /// 既存(グローバル)研修への追加分を、下書きの内容に合わせて保存する(編集にも使う)。
  /// レッスン・問題が両方とも空なら、追加分そのものを削除する。
  Future<void> saveManualExtension({
    required String companyId,
    required String targetModuleId,
    required GeneratedContentDraft draft,
  }) async {
    final extensionRef = _db.doc(FirestorePaths.moduleExtension(companyId, targetModuleId));
    final batch = _db.batch();
    batch.set(extensionRef, {
      'moduleId': targetModuleId,
      'lastTheme': '手動作成',
      'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));
    await _syncChildren(
      batch: batch,
      collection: _db.collection(FirestorePaths.moduleExtensionLessons(companyId, targetModuleId)),
      // 既存レッスンの後ろに並ぶよう、大きめの並び順にする
      items: _lessonItems(targetModuleId, draft, sortBase: 1000),
    );
    await _syncChildren(
      batch: batch,
      collection:
          _db.collection(FirestorePaths.moduleExtensionQuizQuestions(companyId, targetModuleId)),
      items: _questionItems(targetModuleId, draft),
    );
    if (draft.lessons.isEmpty && draft.quizQuestions.isEmpty) {
      batch.delete(extensionRef);
    }
    await batch.commit();
  }

  /// 既存研修への追加分(レッスン・問題)を、編集用の下書きとして読み込む。
  Future<GeneratedContentDraft> loadExtensionDraft(String companyId, String moduleId) async {
    final lessons = await listModuleExtensionLessons(companyId, moduleId);
    final questions = await listModuleExtensionQuizQuestions(companyId, moduleId);
    return _toDraft(null, null, lessons, questions);
  }

  /// オリジナル研修を、編集用の下書きとして読み込む。
  Future<GeneratedContentDraft> loadCustomModuleDraft(CustomModule module) async {
    final lessons = await listCustomModuleLessons(module.companyId, module.id);
    final questions = await listCustomModuleQuizQuestions(module.companyId, module.id);
    return _toDraft(module.title, module.description, lessons, questions);
  }

  GeneratedContentDraft _toDraft(
    String? title,
    String? description,
    List<Lesson> lessons,
    List<QuizQuestion> questions,
  ) {
    return GeneratedContentDraft(
      moduleTitle: title,
      moduleDescription: description,
      lessons: [for (final l in lessons) DraftLesson(id: l.id, title: l.title, body: l.body)],
      quizQuestions: [
        for (final q in questions)
          DraftQuizQuestion(
            id: q.id,
            question: q.question,
            // 編集画面は常に4つの入力欄を出す
            choices: [...q.choices, for (var i = q.choices.length; i < 4; i++) ''],
            correctIndex: q.correctIndex,
            explanation: q.explanation,
          ),
      ],
    );
  }

  Future<List<CustomModule>> listCustomModules(String companyId) async {
    final snap = await _db.collection(FirestorePaths.customModules(companyId)).get();
    final modules = snap.docs.map((d) => CustomModule.fromMap(d.id, d.data())).toList();
    modules.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return modules;
  }

  Stream<List<CustomModule>> watchCustomModules(String companyId) {
    return _db.collection(FirestorePaths.customModules(companyId)).snapshots().map(
          (snap) => snap.docs.map((d) => CustomModule.fromMap(d.id, d.data())).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
        );
  }

  Future<List<Lesson>> listCustomModuleLessons(String companyId, String moduleId) async {
    final snap = await _db
        .collection(FirestorePaths.customModuleLessons(companyId, moduleId))
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => Lesson.fromMap(d.id, d.data())).toList();
  }

  Future<List<QuizQuestion>> listCustomModuleQuizQuestions(
      String companyId, String moduleId) async {
    final snap = await _db
        .collection(FirestorePaths.customModuleQuizQuestions(companyId, moduleId))
        .get();
    return snap.docs.map((d) => QuizQuestion.fromMap(d.id, d.data())).toList();
  }

  /// 会社が既存(グローバル)モジュールに追加したレッスン一覧(未追加なら空リスト)。
  Future<List<Lesson>> listModuleExtensionLessons(String companyId, String moduleId) async {
    final snap = await _db
        .collection(FirestorePaths.moduleExtensionLessons(companyId, moduleId))
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => Lesson.fromMap(d.id, d.data())).toList();
  }

  Future<List<QuizQuestion>> listModuleExtensionQuizQuestions(
      String companyId, String moduleId) async {
    final snap = await _db
        .collection(FirestorePaths.moduleExtensionQuizQuestions(companyId, moduleId))
        .get();
    return snap.docs.map((d) => QuizQuestion.fromMap(d.id, d.data())).toList();
  }

  /// 追加コンテンツが1件以上存在するモジュールIDの集合(一覧画面でのバッジ表示用)。
  Future<Set<String>> listExtendedModuleIds(String companyId) async {
    final snap = await _db.collection(FirestorePaths.moduleExtensions(companyId)).get();
    return snap.docs.map((d) => d.id).toSet();
  }
}
