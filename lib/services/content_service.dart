import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/industry_model.dart';
import '../data/models/module_model.dart';
import '../data/models/lesson_model.dart';
import '../data/models/quiz_question_model.dart';
import '../data/models/category_model.dart';
import '../core/category_priority_resolver.dart';
import 'firestore_paths.dart';

/// 全テナント共通のグローバルコンテンツ（業種プロファイル・モジュール・レッスン・クイズ問題）を読む
class ContentService {
  final FirebaseFirestore _db;
  ContentService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  Future<Industry?> getIndustry(String industryId) async {
    final doc =
        await _db.collection(FirestorePaths.industries).doc(industryId).get();
    if (!doc.exists) return null;
    return Industry.fromMap(doc.id, doc.data()!);
  }

  Future<List<Industry>> listIndustries() async {
    final snap = await _db.collection(FirestorePaths.industries).get();
    return snap.docs.map((d) => Industry.fromMap(d.id, d.data())).toList();
  }

  Future<Module?> getModule(String moduleId) async {
    final doc = await _db.collection(FirestorePaths.modules).doc(moduleId).get();
    if (!doc.exists) return null;
    return Module.fromMap(doc.id, doc.data()!);
  }

  Future<List<Module>> listModulesByCategory(CategoryId categoryId) async {
    final snap = await _db
        .collection(FirestorePaths.modules)
        .where('categoryId', isEqualTo: categoryId.name)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => Module.fromMap(d.id, d.data())).toList();
  }

  /// 業種の優先度順(高→中→低)にモジュール一覧を並べる。
  /// [categoryPriorityOverride]が指定されていれば、会社ごとの個別調整をそちらで優先する。
  Future<List<Module>> listModulesForIndustry(
    Industry industry, {
    Map<String, int> categoryPriorityOverride = const {},
  }) async {
    final snap = await _db.collection(FirestorePaths.modules).get();
    final modules =
        snap.docs.map((d) => Module.fromMap(d.id, d.data())).toList();
    sortModulesByPriority(modules, industry, categoryPriorityOverride);
    return modules;
  }

  /// [modules]を業種の優先度順(高→中→低、同順位はsortOrder昇順)に破壊的にソートする。
  /// listModulesForIndustryと、オリジナルモジュールを合流させた一覧の並び替えの両方で使う
  /// (社員のホーム画面で通常モジュールとオリジナルモジュールを同じ基準で混在表示するため)。
  static void sortModulesByPriority(
    List<Module> modules,
    Industry industry,
    Map<String, int> categoryPriorityOverride,
  ) {
    modules.sort((a, b) {
      final pa = CategoryPriorityResolver.resolve(
        industry: industry,
        categoryId: a.categoryId,
        overrides: categoryPriorityOverride,
      );
      final pb = CategoryPriorityResolver.resolve(
        industry: industry,
        categoryId: b.categoryId,
        overrides: categoryPriorityOverride,
      );
      if (pa != pb) return pb.compareTo(pa); // 優先度高い順
      return a.sortOrder.compareTo(b.sortOrder);
    });
  }

  Future<List<Lesson>> listLessons(String moduleId) async {
    final snap = await _db
        .collection(FirestorePaths.lessons(moduleId))
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => Lesson.fromMap(d.id, d.data())).toList();
  }

  Future<List<QuizQuestion>> listQuizQuestions(String moduleId) async {
    final snap =
        await _db.collection(FirestorePaths.quizQuestions(moduleId)).get();
    return snap.docs
        .map((d) => QuizQuestion.fromMap(d.id, d.data()))
        .toList();
  }

  /// グローバルモジュールのレッスンに、会社がオリジナルコンテンツ機能(プレミアムプラン)で
  /// 追加したレッスンがあれば末尾に連結して返す。
  /// カスタムモジュール(Module.isCustom)には使わないこと(CustomContentServiceを使う)。
  Future<List<Lesson>> listLessonsForCompany(String moduleId, String companyId) async {
    final base = await listLessons(moduleId);
    final extensionSnap = await _db
        .collection(FirestorePaths.moduleExtensionLessons(companyId, moduleId))
        .orderBy('sortOrder')
        .get();
    final extension =
        extensionSnap.docs.map((d) => Lesson.fromMap(d.id, d.data())).toList();
    return [...base, ...extension];
  }

  /// listLessonsForCompanyのクイズ問題版。submitQuizAttempt Cloud Function側の
  /// 採点ロジック(グローバル問題→追加問題の順で合算)と並び順を一致させること。
  Future<List<QuizQuestion>> listQuizQuestionsForCompany(
      String moduleId, String companyId) async {
    final base = await listQuizQuestions(moduleId);
    final extensionSnap = await _db
        .collection(FirestorePaths.moduleExtensionQuizQuestions(companyId, moduleId))
        .get();
    final extension =
        extensionSnap.docs.map((d) => QuizQuestion.fromMap(d.id, d.data())).toList();
    return [...base, ...extension];
  }
}
