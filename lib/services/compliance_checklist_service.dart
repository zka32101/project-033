import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_paths.dart';

/// 法令対応チェックリストの実施状況(会社ごと)を保存・取得する。
class ComplianceChecklistService {
  final FirebaseFirestore _db;

  ComplianceChecklistService(this._db);

  /// 項目ID -> 完了済みか。
  Stream<Map<String, bool>> watchStatuses(String companyId) {
    return _db.collection(FirestorePaths.complianceChecklist(companyId)).snapshots().map(
          (snap) => {
            for (final d in snap.docs) d.id: (d.data()['done'] as bool?) ?? false,
          },
        );
  }

  Future<void> setDone({
    required String companyId,
    required String itemId,
    required bool done,
  }) {
    return _db.doc('${FirestorePaths.complianceChecklist(companyId)}/$itemId').set({
      'done': done,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
