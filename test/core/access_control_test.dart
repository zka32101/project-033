import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/access_control.dart';
import 'package:safy/data/models/subscription_model.dart';

Subscription _subscription({
  required List<String> moduleIds,
  bool fullSet = false,
  SubscriptionStatus status = SubscriptionStatus.active,
  ModulePlanTier planTier = ModulePlanTier.upper,
  PremiumTier premiumTier = PremiumTier.none,
}) {
  return Subscription(
    id: 's1',
    ownerType: SubscriptionOwnerType.company,
    ownerId: 'c1',
    subscribedModuleIds: moduleIds,
    fullSet: fullSet,
    headcount: 20,
    status: status,
    planTier: planTier,
    premiumTier: premiumTier,
    startedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('AccessControl.moduleAccessGranted', () {
    test('無料体験モジュールは契約なしでもアクセス可', () {
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: true,
          subscription: null,
          moduleId: 'm1',
        ),
        isTrue,
      );
    });

    test('契約がなければ有料モジュールにアクセス不可', () {
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: false,
          subscription: null,
          moduleId: 'm1',
        ),
        isFalse,
      );
    });

    test('契約モジュールに含まれていればアクセス可', () {
      final sub = _subscription(moduleIds: ['m1', 'm2']);
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: false,
          subscription: sub,
          moduleId: 'm1',
        ),
        isTrue,
      );
    });

    test('契約モジュールに含まれていなければアクセス不可', () {
      final sub = _subscription(moduleIds: ['m2']);
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: false,
          subscription: sub,
          moduleId: 'm1',
        ),
        isFalse,
      );
    });

    test('fullSet契約は全モジュールにアクセス可', () {
      final sub = _subscription(moduleIds: [], fullSet: true);
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: false,
          subscription: sub,
          moduleId: 'm-anything',
        ),
        isTrue,
      );
    });

    test('契約がexpired状態ならアクセス不可', () {
      final sub = _subscription(
        moduleIds: ['m1'],
        status: SubscriptionStatus.expired,
      );
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: false,
          subscription: sub,
          moduleId: 'm1',
        ),
        isFalse,
      );
    });

    test('基本プランは選択モジュールを含んでいてもアクセス不可(無料体験のみが対象)', () {
      final sub = _subscription(
        moduleIds: ['m1'],
        planTier: ModulePlanTier.basic,
      );
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: false,
          subscription: sub,
          moduleId: 'm1',
        ),
        isFalse,
      );
    });

    test('基本プランでもfullSetが立っていればアクセス不可(upperプラン限定)', () {
      final sub = _subscription(
        moduleIds: [],
        fullSet: true,
        planTier: ModulePlanTier.basic,
      );
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: false,
          subscription: sub,
          moduleId: 'm-anything',
        ),
        isFalse,
      );
    });

    test('上位プランに切り替えると同じ選択モジュールにアクセス可になる', () {
      final sub = _subscription(
        moduleIds: ['m1'],
        planTier: ModulePlanTier.upper,
      );
      expect(
        AccessControl.moduleAccessGranted(
          isFreeTrial: false,
          subscription: sub,
          moduleId: 'm1',
        ),
        isTrue,
      );
    });
  });

  group('AccessControl.canExtendExistingModules / canCreateOriginalModules', () {
    test('契約がなければどちらも不可', () {
      expect(AccessControl.canExtendExistingModules(null), isFalse);
      expect(AccessControl.canCreateOriginalModules(null), isFalse);
    });

    test('premiumTier=noneならどちらも不可', () {
      final sub = _subscription(moduleIds: const []);
      expect(AccessControl.canExtendExistingModules(sub), isFalse);
      expect(AccessControl.canCreateOriginalModules(sub), isFalse);
    });

    test('premiumTier=moduleExtensionは追加のみ可・新規作成は不可', () {
      final sub = _subscription(
        moduleIds: const [],
        premiumTier: PremiumTier.moduleExtension,
      );
      expect(AccessControl.canExtendExistingModules(sub), isTrue);
      expect(AccessControl.canCreateOriginalModules(sub), isFalse);
    });

    test('premiumTier=moduleCreationはどちらも可(上位互換)', () {
      final sub = _subscription(
        moduleIds: const [],
        premiumTier: PremiumTier.moduleCreation,
      );
      expect(AccessControl.canExtendExistingModules(sub), isTrue);
      expect(AccessControl.canCreateOriginalModules(sub), isTrue);
    });

    test('expired状態ならpremiumTierに関わらず不可', () {
      final sub = _subscription(
        moduleIds: const [],
        status: SubscriptionStatus.expired,
        premiumTier: PremiumTier.moduleCreation,
      );
      expect(AccessControl.canExtendExistingModules(sub), isFalse);
      expect(AccessControl.canCreateOriginalModules(sub), isFalse);
    });
  });
}
