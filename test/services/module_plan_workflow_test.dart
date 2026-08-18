import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:safy/services/subscription_service.dart';
import 'package:safy/core/access_control.dart';
import 'package:safy/data/models/subscription_model.dart';

/// 利用者数に応じた課金体系(基本プラン/上位プラン)の一連の流れを検証する。
/// 基本プランは無料体験モジュール相当に限定され、上位プランでのみ選択した
/// モジュールにアクセスできる。料金は選択モジュール数に関わらず人数のみで決まる。
void main() {
  late FakeFirebaseFirestore db;
  late SubscriptionService subscriptionService;

  const companyId = 'company-1';

  setUp(() {
    db = FakeFirebaseFirestore();
    subscriptionService = SubscriptionService(db);
  });

  test('契約前は無料体験モジュールのみアクセス可', () async {
    final subscription = await subscriptionService.getActiveSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
    );
    expect(subscription, isNull);

    expect(
      AccessControl.moduleAccessGranted(
        isFreeTrial: true,
        subscription: subscription,
        moduleId: 'm_ethics_sns',
      ),
      isTrue,
    );
    expect(
      AccessControl.moduleAccessGranted(
        isFreeTrial: false,
        subscription: subscription,
        moduleId: 'm_security_basics',
      ),
      isFalse,
    );
  });

  test('基本プランに加入しても無料体験を超えるモジュールにはアクセスできない', () async {
    await subscriptionService.upsertSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
      subscribedModuleIds: const [],
      fullSet: false,
      headcount: 15,
      planTier: ModulePlanTier.basic,
    );

    final subscription = await subscriptionService.getActiveSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
    );
    expect(subscription!.planTier, ModulePlanTier.basic);

    expect(
      AccessControl.moduleAccessGranted(
        isFreeTrial: false,
        subscription: subscription,
        moduleId: 'm_security_basics',
      ),
      isFalse,
    );

    // 基本プランの月額は人数のみで決まる(15名 → 20名以下ブロック=100円/人)
    final price = SubscriptionService.monthlyPriceYen(
      headcount: 15,
      planTier: subscription.planTier,
    );
    expect(price, 100 * 15);
  });

  test('上位プランに切り替えてモジュールを選択すると、そのモジュールにアクセスできる', () async {
    await subscriptionService.upsertSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
      subscribedModuleIds: ['m_security_basics', 'm_privacy_basics'],
      fullSet: false,
      headcount: 15,
      planTier: ModulePlanTier.upper,
    );

    final subscription = await subscriptionService.getActiveSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
    );
    expect(subscription!.planTier, ModulePlanTier.upper);

    expect(
      AccessControl.moduleAccessGranted(
        isFreeTrial: false,
        subscription: subscription,
        moduleId: 'm_security_basics',
      ),
      isTrue,
    );
    expect(
      AccessControl.moduleAccessGranted(
        isFreeTrial: false,
        subscription: subscription,
        moduleId: 'm_compliance_basics',
      ),
      isFalse,
      reason: '選択していないモジュールは上位プランでも対象外',
    );

    // 上位プランの月額は選択モジュール数(2件)に関わらず人数のみで決まる(15名 → 20名以下ブロック=400円/人)
    final priceWithTwoModules = SubscriptionService.monthlyPriceYen(
      headcount: 15,
      planTier: subscription.planTier,
    );
    expect(priceWithTwoModules, 400 * 15);

    // モジュールを1つ追加選択しても料金は変わらない
    await subscriptionService.upsertSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
      subscribedModuleIds: ['m_security_basics', 'm_privacy_basics', 'm_compliance_basics'],
      fullSet: false,
      headcount: 15,
      planTier: ModulePlanTier.upper,
    );
    final priceWithThreeModules = SubscriptionService.monthlyPriceYen(
      headcount: 15,
      planTier: ModulePlanTier.upper,
    );
    expect(priceWithThreeModules, priceWithTwoModules);
  });

  test('上位プランから基本プランに戻すと選択済みモジュールへのアクセスを失う', () async {
    await subscriptionService.upsertSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
      subscribedModuleIds: ['m_security_basics'],
      fullSet: false,
      headcount: 15,
      planTier: ModulePlanTier.upper,
    );

    // 基本プランへダウングレード(選択済みモジュールのリストは変更しない呼び出しでも、
    // planTierがbasicになれば上位プラン限定のアクセスは失われる)。
    await subscriptionService.upsertSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
      subscribedModuleIds: ['m_security_basics'],
      fullSet: false,
      headcount: 15,
      planTier: ModulePlanTier.basic,
    );

    final subscription = await subscriptionService.getActiveSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
    );
    expect(subscription!.planTier, ModulePlanTier.basic);
    expect(
      AccessControl.moduleAccessGranted(
        isFreeTrial: false,
        subscription: subscription,
        moduleId: 'm_security_basics',
      ),
      isFalse,
    );
  });

  test('premiumTierを更新してもplanTierは維持される(upsertPremiumTier)', () async {
    await subscriptionService.upsertSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
      subscribedModuleIds: ['m_security_basics'],
      fullSet: false,
      headcount: 15,
      planTier: ModulePlanTier.upper,
    );

    await subscriptionService.upsertPremiumTier(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
      premiumTier: PremiumTier.moduleCreation,
      headcount: 15,
    );

    final subscription = await subscriptionService.getActiveSubscription(
      companyId: companyId,
      ownerType: SubscriptionOwnerType.company,
      ownerId: companyId,
    );
    expect(subscription!.planTier, ModulePlanTier.upper,
        reason: 'プレミアムプラン更新でモジュール受講プランがリセットされてはいけない');
    expect(subscription.subscribedModuleIds, ['m_security_basics']);
    expect(subscription.premiumTier, PremiumTier.moduleCreation);
  });
}
