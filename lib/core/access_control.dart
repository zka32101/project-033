import '../data/models/subscription_model.dart';

/// モジュールへのアクセス可否判定(設計書 Step3.5 R④: 無料体験→追加モジュール課金訴求)。
/// Firestore/UIに依存しない純粋ロジックなのでユニットテストで検証する。
class AccessControl {
  static bool moduleAccessGranted({
    required bool isFreeTrial,
    required Subscription? subscription,
    required String moduleId,
  }) {
    if (isFreeTrial) return true;
    if (subscription == null) return false;
    if (subscription.status != SubscriptionStatus.active) return false;
    return subscription.hasAccessToModule(moduleId);
  }
}
