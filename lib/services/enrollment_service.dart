import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/enrollment_model.dart';
import '../data/models/progress_record_model.dart';
import 'firestore_paths.dart';

class EnrollmentService {
  final FirebaseFirestore _db;
  EnrollmentService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  /// employeeId+moduleIdから決定的なドキュメントIDを作ることで、二重タップ・リトライ時に
  /// クエリのread→writeが競合しても重複ドキュメントが生まれないようにする(同じIDへの上書きになる)。
  String _employeeModuleDocId(String employeeId, String moduleId) =>
      '${employeeId}_$moduleId';

  Future<Enrollment> startModule({
    required String companyId,
    required String employeeId,
    required String moduleId,
  }) async {
    final ref = _db.doc(
        '${FirestorePaths.enrollments(companyId)}/${_employeeModuleDocId(employeeId, moduleId)}');
    final existing = await ref.get();
    if (existing.exists) {
      return Enrollment.fromMap(existing.id, existing.data()!);
    }
    final enrollment = Enrollment(
      id: ref.id,
      employeeId: employeeId,
      moduleId: moduleId,
      status: EnrollmentStatus.inProgress,
      startedAt: DateTime.now(),
    );
    await ref.set(enrollment.toMap());
    return enrollment;
  }

  Future<void> markCompleted({
    required String companyId,
    required String enrollmentId,
  }) async {
    // set+mergeを使うことで、稀にEnrollmentドキュメントが未作成のまま合格した場合でも
    // NotFoundで例外にならず安全に完了状態を書き込める(update()だと未存在時に失敗する)。
    await _db
        .doc('${FirestorePaths.enrollments(companyId)}/$enrollmentId')
        .set({
      'status': EnrollmentStatus.completed.name,
      'completedAt': DateTime.now(),
    }, SetOptions(merge: true));
  }

  /// クイズ合格時に結果画面から呼ぶ。該当のEnrollmentをmarkCompletedする。
  Future<void> completeModuleForEmployee({
    required String companyId,
    required String employeeId,
    required String moduleId,
  }) async {
    await markCompleted(
      companyId: companyId,
      enrollmentId: _employeeModuleDocId(employeeId, moduleId),
    );
  }

  Stream<List<Enrollment>> watchEmployeeEnrollments(
      String companyId, String employeeId) {
    return _db
        .collection(FirestorePaths.enrollments(companyId))
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Enrollment.fromMap(d.id, d.data())).toList());
  }

  /// 管理者ダッシュボード用: 会社内全社員の受講記録
  Stream<List<Enrollment>> watchCompanyEnrollments(String companyId) {
    return _db
        .collection(FirestorePaths.enrollments(companyId))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Enrollment.fromMap(d.id, d.data())).toList());
  }

  Future<ProgressRecord> recordLessonViewed({
    required String companyId,
    required String employeeId,
    required String moduleId,
    required String lessonId,
  }) async {
    final ref = _db.doc(
        '${FirestorePaths.progressRecords(companyId)}/${_employeeModuleDocId(employeeId, moduleId)}');
    final existingDoc = await ref.get();

    if (!existingDoc.exists) {
      final record = ProgressRecord(
        id: ref.id,
        employeeId: employeeId,
        moduleId: moduleId,
        completedLessonIds: [lessonId],
        lastAccessedAt: DateTime.now(),
      );
      await ref.set(record.toMap());
      return record;
    }

    final existing = ProgressRecord.fromMap(existingDoc.id, existingDoc.data()!);
    final updatedIds = {...existing.completedLessonIds, lessonId}.toList();
    final updated = existing.copyWith(
      completedLessonIds: updatedIds,
      lastAccessedAt: DateTime.now(),
    );
    await ref.set(updated.toMap());
    return updated;
  }
}
