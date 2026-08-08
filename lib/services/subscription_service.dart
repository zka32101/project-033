import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/subscription_model.dart';
import 'firestore_paths.dart';

/// モジュール課金・人数割引の価格計算とアクセス可否判定。
/// 実際の決済処理はRevenueCat(purchases_flutter)経由、本サービスはFirestore側の権利管理を担う。
class SubscriptionService {
  final FirebaseFirestore _db;
  SubscriptionService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  /// 設計書 Section2 モジュール制＋人数ボリュームディスカウント
  static int moduleUnitPriceYen(int headcount) {
    if (headcount <= 20) return 100;
    if (headcount <= 50) return 90;
    if (headcount <= 100) return 80;
    return 0; // 101名以上は個別見積(価格未確定)
  }

  static int fullSetUnitPriceYen(int headcount) {
    if (headcount <= 20) return 400;
    if (headcount <= 50) return 360;
    if (headcount <= 100) return 320;
    return 0; // 101名以上は個別見積
  }

  static int monthlyPriceYen({
    required int headcount,
    required int moduleCount,
    required bool fullSet,
  }) {
    if (fullSet) return fullSetUnitPriceYen(headcount) * headcount;
    return moduleUnitPriceYen(headcount) * moduleCount * headcount;
  }

  /// owner(個人 or 企業)につき有効な契約は1件のみという前提を、決定的なドキュメントIDで
  /// 保証する。read→writeの競合で重複した有効サブスクリプションが生まれることを防ぐ
  /// (旧実装はクエリで既存確認→ランダムIDで新規作成しており、同時書き込みで重複しうった)。
  String _subscriptionDocId(SubscriptionOwnerType ownerType, String ownerId) =>
      '${ownerType.name}_$ownerId';

  Future<Subscription?> getActiveSubscription({
    required String companyId,
    required SubscriptionOwnerType ownerType,
    required String ownerId,
  }) async {
    final doc = await _db
        .doc('${FirestorePaths.subscriptions(companyId)}/${_subscriptionDocId(ownerType, ownerId)}')
        .get();
    if (!doc.exists) return null;
    final subscription = Subscription.fromMap(doc.id, doc.data()!);
    if (subscription.status != SubscriptionStatus.active) return null;
    return subscription;
  }

  Future<Subscription> upsertSubscription({
    required String companyId,
    required SubscriptionOwnerType ownerType,
    required String ownerId,
    required List<String> subscribedModuleIds,
    required bool fullSet,
    required int headcount,
  }) async {
    final ref = _db.doc(
        '${FirestorePaths.subscriptions(companyId)}/${_subscriptionDocId(ownerType, ownerId)}');
    final existingDoc = await ref.get();
    final existing =
        existingDoc.exists ? Subscription.fromMap(existingDoc.id, existingDoc.data()!) : null;
    final subscription = Subscription(
      id: ref.id,
      ownerType: ownerType,
      ownerId: ownerId,
      subscribedModuleIds: subscribedModuleIds,
      fullSet: fullSet,
      headcount: headcount,
      status: SubscriptionStatus.active,
      startedAt: existing?.startedAt ?? DateTime.now(),
    );
    await ref.set(subscription.toMap());
    return subscription;
  }
}
