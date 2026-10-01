import 'package:firebase_auth/firebase_auth.dart';

/// 管理者が会社・チーム・メンバーを書き換えるとき、書き込みに「誰が行ったか(uid)」を添える。
/// firestore.rulesが、この値が本人のuidと一致しない書き込みを拒否するため、偽装できない。
/// サーバーの監査ログ(Cloud Functions)は、この値から操作者を記録する。
class EditorStamp {
  const EditorStamp._();

  /// 現在サインイン中のuid。テストでは差し替えられる。
  static String? Function() uidProvider = _firebaseUid;

  static String? _firebaseUid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null; // Firebase未初期化(テストなど)
    }
  }

  /// 書き込みのフィールドに展開する(`{...EditorStamp.fields(), 'x': 1}`)。
  static Map<String, Object> fields() {
    final uid = uidProvider();
    return uid == null ? const {} : {'lastEditedBy': uid};
  }
}
