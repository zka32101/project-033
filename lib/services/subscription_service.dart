import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/subscription_model.dart';
import 'firestore_paths.dart';

/// モジュール課金・人数割引の価格計算とアクセス可否判定。
/// 実際の決済処理はRevenueCat(purchases_flutter)経由、本サービスはFirestore側の権利管理を担う。
class SubscriptionService {
  final FirebaseFirestore _db;
  SubscriptionService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  /// 利用者数(headcount)に応じた課金体系。モジュール数に関わらず定額
  /// (basic=無料体験モジュール相当のみ、upper=カテゴリごとに選択したモジュールが対象)。
  /// 人数が増えるほど1人あたり単価が下がるボリュームディスカウントは維持する。
  static int basicPlanUnitPriceYen(int headcount) {
    if (headcount <= 20) return 100;
    if (headcount <= 50) return 90;
    if (headcount <= 100) return 80;
    return 0; // 101名以上は個別見積(価格未確定)
  }

  static int upperPlanUnitPriceYen(int headcount) {
    if (headcount <= 20) return 400;
    if (headcount <= 50) return 360;
    if (headcount <= 100) return 320;
    return 0; // 101名以上は個別見積
  }

  static int planUnitPriceYen(ModulePlanTier tier, int headcount) {
    return tier == ModulePlanTier.upper
        ? upperPlanUnitPriceYen(headcount)
        : basicPlanUnitPriceYen(headcount);
  }

  /// 月額料金 = 1人あたり単価 × 人数。選択したモジュール数では変動しない。
  static int monthlyPriceYen({
    required int headcount,
    required ModulePlanTier planTier,
  }) {
    return planUnitPriceYen(planTier, headcount) * headcount;
  }

  /// オリジナルコンテンツ機能(プレミアムプラン)の月額固定料金。
  /// コンテンツ作成は会社単位の機能のため、モジュール課金と異なり人数割引は適用しない。
  static int premiumTierMonthlyPriceYen(PremiumTier tier) {
    switch (tier) {
      case PremiumTier.none:
        return 0;
      case PremiumTier.moduleExtension:
        return 15000; // 既存モジュールへのレッスン/クイズ追加
      case PremiumTier.moduleCreation:
        return 30000; // 新規オリジナルモジュール作成(既存モジュール追加も含む)
    }
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
    final expiresAt = subscription.expiresAt;
    if (expiresAt != null && !expiresAt.isAfter(DateTime.now())) return null;
    return subscription;
  }

  /// 基本プラン(basic)への加入・維持、または上位プラン(upper)でのモジュール選択更新に使う。
  /// planTier未指定時は既存の契約段階を維持する(他の更新でbasic/upperが意図せず
  /// リセットされないようにするため。新規契約時のデフォルトはbasic)。
  Future<Subscription> upsertSubscription({
    required String companyId,
    required SubscriptionOwnerType ownerType,
    required String ownerId,
    required List<String> subscribedModuleIds,
    required bool fullSet,
    required int headcount,
    ModulePlanTier? planTier,
    PremiumTier? premiumTier,
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
      planTier: planTier ?? existing?.planTier ?? ModulePlanTier.basic,
      // premiumTier未指定の場合は既存契約の値を維持する(モジュール追加購入がプレミアム
      // プランを意図せずnoneへリセットしてしまわないようにするため)。
      premiumTier: premiumTier ?? existing?.premiumTier ?? PremiumTier.none,
      startedAt: existing?.startedAt ?? DateTime.now(),
    );
    await ref.set(subscription.toMap());
    return subscription;
  }

  /// プレミアムプラン(オリジナルコンテンツ機能)単体のアップグレード用。
  /// モジュール受講プラン(planTier/subscribedModuleIds/fullSet)には触れない。
  Future<Subscription> upsertPremiumTier({
    required String companyId,
    required SubscriptionOwnerType ownerType,
    required String ownerId,
    required PremiumTier premiumTier,
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
      subscribedModuleIds: existing?.subscribedModuleIds ?? const [],
      fullSet: existing?.fullSet ?? false,
      headcount: headcount,
      status: SubscriptionStatus.active,
      planTier: existing?.planTier ?? ModulePlanTier.basic,
      premiumTier: premiumTier,
      startedAt: existing?.startedAt ?? DateTime.now(),
    );
    await ref.set(subscription.toMap());
    return subscription;
  }
}
