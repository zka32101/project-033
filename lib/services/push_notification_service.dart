import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firestore_paths.dart';

/// 未受講者リマインド・法改正お知らせのプッシュ配信基盤(設計書 Step7)。
/// 実際の配信はCloud Functionsトリガー(reminders/moduleDeadlines監視)から行う想定。
/// 本サービスはトークン登録に加え、アプリがフォアグラウンドの間に届いた通知を
/// 画面上に表示する処理(flutter_local_notifications)も担う。
/// バックグラウンド/終了時はFCMがOS側で自動的に通知を表示するため対応不要だが、
/// フォアグラウンド時はFirebaseMessaging.onMessageで受信するだけで何もしないと
/// ユーザーに何も表示されず通知が無視されたように見えてしまうため。
/// Firebase Console本設定完了後、main.dartからinitialize()を呼び出す([flutter-firebase-setup]参照)。
class PushNotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _db;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static const _androidChannel = AndroidNotificationChannel(
    'deadline_reminders',
    '受講期限・リマインド通知',
    description: '受講期限が近い/過ぎたモジュールや管理者からの個別リマインドをお知らせします',
    importance: Importance.high,
  );

  bool _foregroundListenerAttached = false;

  PushNotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? db,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _db = db ?? FirebaseFirestore.instance,
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();

  Future<void> registerToken({
    required String companyId,
    required String employeeId,
  }) async {
    await _messaging.requestPermission();
    await _initLocalNotifications();
    _listenForegroundMessages();
    final token = await _messaging.getToken();
    if (token == null) return;
    await _db.doc(FirestorePaths.employee(companyId, employeeId)).update({
      'fcmToken': token,
    });
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOSの通知許可は直前のFirebaseMessaging.requestPermission()で既にリクエスト済みのため、
    // ここで重ねてリクエストしない(二重のパーミッションダイアログを避ける)。
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  /// アプリがフォアグラウンドの間に届いたFCM通知は、OS側では自動表示されず
  /// FirebaseMessaging.onMessageストリームに流れるだけになる。ここで購読して
  /// ローカル通知として明示的に表示することで、バックグラウンド時と同じ体験にする。
  void _listenForegroundMessages() {
    if (_foregroundListenerAttached) return;
    _foregroundListenerAttached = true;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        // AndroidのNotification IDは32bit int前提のため、hashCodeをその範囲にマスクする。
        id: notification.hashCode & 0x7fffffff,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });
  }
}
