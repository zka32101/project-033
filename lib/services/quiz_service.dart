import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../data/models/quiz_attempt_model.dart';
import '../data/models/quiz_question_model.dart';
import '../data/models/completion_certificate_model.dart';
import 'firestore_paths.dart';

/// クイズ提出・監査証跡発行。
/// QuizAttempt/CompletionCertificateは監査証跡のため改ざん防止が必須(設計書Step5) →
/// クライアントから直接書き込まず Cloud Functions callable 経由に統一する。
class QuizService {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  QuizService({FirebaseFirestore? db, FirebaseFunctions? functions})
      : _db = db ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  /// クライアント側でスコアをプレビュー表示するための即時判定(表示専用・保存はCloud Functions側で再計算)
  QuizAttempt previewResult({
    required String employeeId,
    required String moduleId,
    required List<int> selectedAnswers,
    required List<QuizQuestion> questions,
    required int thresholdApplied,
  }) {
    return QuizAttempt.evaluate(
      id: 'preview',
      employeeId: employeeId,
      moduleId: moduleId,
      selectedAnswers: selectedAnswers,
      correctIndexes: questions.map((q) => q.correctIndex).toList(),
      thresholdApplied: thresholdApplied,
      answeredAt: DateTime.now(),
    );
  }

  /// Cloud Functions `submitQuizAttempt` を呼び出し、正式なQuizAttempt保存と
  /// 合格時のCompletionCertificate発行をサーバー側で行わせる。
  Future<QuizAttempt> submitAttempt({
    required String companyId,
    required String employeeId,
    required String moduleId,
    required List<int> selectedAnswers,
  }) async {
    final result = await _functions.httpsCallable('submitQuizAttempt').call({
      'companyId': companyId,
      'employeeId': employeeId,
      'moduleId': moduleId,
      'selectedAnswers': selectedAnswers,
    });
    final data = Map<String, dynamic>.from(result.data as Map);
    return QuizAttempt.fromMap(data['attemptId'] as String, data);
  }

  Stream<List<QuizAttempt>> watchAttempts(String companyId, String employeeId) {
    return _db
        .collection(FirestorePaths.quizAttempts(companyId))
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList());
  }

  /// 管理者ダッシュボード用: 会社内全社員のクイズ受験記録
  Stream<List<QuizAttempt>> watchCompanyAttempts(String companyId) {
    return _db
        .collection(FirestorePaths.quizAttempts(companyId))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => QuizAttempt.fromMap(d.id, d.data())).toList());
  }

  Stream<List<CompletionCertificate>> watchCertificates(
      String companyId, String employeeId) {
    return _db
        .collection(FirestorePaths.certificates(companyId))
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CompletionCertificate.fromMap(d.id, d.data()))
            .toList());
  }
}
