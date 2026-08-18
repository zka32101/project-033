import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/access_control.dart';
import 'package:safy/data/models/subscription_model.dart';

Subscription _subscription({
  required List<String> moduleIds,
  bool fullSet = false,
  SubscriptionStatus status = SubscriptionStatus.active,
}) {
  return Subscription(
    id: 's1',
    ownerType: SubscriptionOwnerType.company,
    ownerId: 'c1',
    subscribedModuleIds: moduleIds,
    fullSet: fullSet,
    headcount: 20,
    status: status,
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
  });
}
