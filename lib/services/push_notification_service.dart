import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firestore_paths.dart';

/// 未受講者リマインド・法改正お知らせのプッシュ配信基盤(設計書 Step7)。
/// 実際の配信はCloud Functionsトリガー(reminders/notices書き込みを監視)から行う想定。
/// 本サービスはトークン登録のみを担い、Firebase Console本設定完了後に
/// main.dartからinitialize()を呼び出す([flutter-firebase-setup]参照)。
class PushNotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _db;

  PushNotificationService({FirebaseMessaging? messaging, FirebaseFirestore? db})
      : _messaging = messaging ?? FirebaseMessaging.instance,
        _db = db ?? FirebaseFirestore.instance;

  Future<void> registerToken({
    required String companyId,
    required String employeeId,
  }) async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    if (token == null) return;
    await _db.doc(FirestorePaths.employee(companyId, employeeId)).update({
      'fcmToken': token,
    });
  }
}
