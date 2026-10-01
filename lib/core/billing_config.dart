/// 契約・課金まわりの設定値。公開前に実際の値へ差し替える。
class BillingConfig {
  const BillingConfig._();

  /// ストア課金(Google Play)で契約できるか。商品・料金が整うまでfalse。
  static const bool storeBillingAvailable = false;
}
