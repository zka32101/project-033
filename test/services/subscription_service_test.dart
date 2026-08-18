import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:safy/services/subscription_service.dart';
import 'package:safy/services/firestore_paths.dart';
import 'package:safy/data/models/subscription_model.dart';

/// getActiveSubscriptionの有効期限判定を検証する。
/// statusのみでexpiresAtを見ないと、期限切れ後もアクセスが通り続けてしまうバグの回帰テスト。
void main() {
  late FakeFirebaseFirestore db;
  late SubscriptionService subscriptionService;

  const companyId = 'company-1';
  const ownerId = 'company-1';

  setUp(() {
    db = FakeFirebaseFirestore();
    subscriptionService = SubscriptionService(db);
  });

  Future<void> seedSubscription({
    required String status,
    DateTime? expiresAt,
  }) async {
    final docId =
        '${SubscriptionOwnerType.company.name}_$ownerId';
    await db.doc('${FirestorePaths.subscriptions(companyId)}/$docId').set({
      'ownerType': 'company',
      'ownerId': ownerId,
      'subscribedModuleIds': ['m_ethics_sns'],
      'fullSet': false,
      'headcount': 20,
      'status': status,
      'startedAt': DateTime(2026, 1, 1),
      'expiresAt': expiresAt,
    });
  }

  group('SubscriptionService.getActiveSubscription: 有効期限判定', () {
    test('statusがactiveでexpiresAt未設定なら取得できる', () async {
      await seedSubscription(status: 'active', expiresAt: null);

      final result = await subscriptionService.getActiveSubscription(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: ownerId,
      );

      expect(result, isNotNull);
    });

    test('statusがactiveでもexpiresAtが過去ならアクセス権を返さない', () async {
      await seedSubscription(
        status: 'active',
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      final result = await subscriptionService.getActiveSubscription(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: ownerId,
      );

      expect(result, isNull);
    });

    test('statusがactiveでexpiresAtが未来なら取得できる', () async {
      await seedSubscription(
        status: 'active',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      final result = await subscriptionService.getActiveSubscription(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: ownerId,
      );

      expect(result, isNotNull);
    });

    test('statusがexpiredならexpiresAtに関わらず取得できない', () async {
      await seedSubscription(
        status: 'expired',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      final result = await subscriptionService.getActiveSubscription(
        companyId: companyId,
        ownerType: SubscriptionOwnerType.company,
        ownerId: ownerId,
      );

      expect(result, isNull);
    });
  });
}
