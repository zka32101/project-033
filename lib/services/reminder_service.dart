import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_paths.dart';

/// 個別リマインド送信の記録。実プッシュ配信(FCM)はRetentionフェーズで
/// Cloud Functionsトリガーとして実装し、本サービスはリクエストの記録のみ担う。
class ReminderService {
  final FirebaseFirestore _db;
  ReminderService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  Future<void> sendReminder({
    required String companyId,
    required String employeeId,
    required String moduleId,
  }) async {
    final ref = _db.collection(FirestorePaths.reminders(companyId)).doc();
    await ref.set({
      'employeeId': employeeId,
      'moduleId': moduleId,
      'sentAt': DateTime.now(),
    });
  }

  Stream<List<String>> watchRemindedEmployeeIds({
    required String companyId,
    required String moduleId,
  }) {
    return _db
        .collection(FirestorePaths.reminders(companyId))
        .where('moduleId', isEqualTo: moduleId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => d.data()['employeeId'] as String).toList());
  }
}
