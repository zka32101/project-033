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
