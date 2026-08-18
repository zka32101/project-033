import '../data/models/subscription_model.dart';

/// モジュールへのアクセス可否判定(設計書 Step3.5 R④: 無料体験→追加モジュール課金訴求)。
/// 利用者数(headcount)に応じた課金体系: 基本プラン(basic)は無料体験モジュール相当に
/// 限定され、上位プラン(upper)でカテゴリごとに選択したモジュール(fullSetなら全て)に
/// アクセスできる。Firestore/UIに依存しない純粋ロジックなのでユニットテストで検証する。
class AccessControl {
  static bool moduleAccessGranted({
    required bool isFreeTrial,
    required Subscription? subscription,
    required String moduleId,
  }) {
    if (isFreeTrial) return true;
    if (subscription == null) return false;
    if (subscription.status != SubscriptionStatus.active) return false;
    // basicプランは無料体験モジュールのみが対象(hasAccessToModuleはupperプラン時のみtrueになる)。
    return subscription.hasAccessToModule(moduleId);
  }

  /// オリジナルコンテンツ機能(既存モジュールへの追加/新規モジュール作成)の利用可否判定。
  static bool canExtendExistingModules(Subscription? subscription) {
    if (subscription == null) return false;
    if (subscription.status != SubscriptionStatus.active) return false;
    return subscription.canExtendExistingModules;
  }

  static bool canCreateOriginalModules(Subscription? subscription) {
    if (subscription == null) return false;
    if (subscription.status != SubscriptionStatus.active) return false;
    return subscription.canCreateOriginalModules;
  }
}
