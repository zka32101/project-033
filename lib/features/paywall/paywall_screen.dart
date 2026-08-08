import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/module_model.dart';
import '../../data/models/subscription_model.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../../services/subscription_service.dart';
import '../lesson/lesson_screen.dart';

/// ペイウォール(設計書 Step3.5 R④): 業種の高優先カテゴリ1つ無料体験→Aha直後に追加課金訴求。
/// A/B軸: セット(全カテゴリ込み)推奨表示 vs モジュール個別選択。
/// 実際の決済はRevenueCat(purchases_flutter)経由で行う想定。ストア審査・課金設定が
/// 完了するまでは、契約状態をFirestoreに直接反映するプレースホルダー動線とする。
class PaywallScreen extends ConsumerStatefulWidget {
  final Module module;

  const PaywallScreen({super.key, required this.module});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isProcessing = false;

  Future<void> _purchase({required bool fullSet}) async {
    final session = ref.read(sessionProvider);
    if (!session.isSignedIn) return;
    setState(() => _isProcessing = true);

    try {
      final company = session.company!;
      final subscriptionService = ref.read(subscriptionServiceProvider);
      final existing = await subscriptionService.getActiveSubscription(
        companyId: company.id,
        ownerType: SubscriptionOwnerType.company,
        ownerId: company.id,
      );
      final moduleIds = {
        ...?existing?.subscribedModuleIds,
        widget.module.id,
      }.toList();

      await subscriptionService.upsertSubscription(
        companyId: company.id,
        ownerType: SubscriptionOwnerType.company,
        ownerId: company.id,
        subscribedModuleIds: moduleIds,
        fullSet: fullSet || (existing?.fullSet ?? false),
        headcount: company.contractedHeadcount,
      );
      await ref.read(analyticsServiceProvider).logSubscriptionUpgraded(
            companyId: company.id,
            fullSet: fullSet,
            moduleCount: moduleIds.length,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LessonScreen(module: widget.module)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('契約処理に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final headcount = session.company?.contractedHeadcount ?? 1;
    final moduleUnitPrice = SubscriptionService.moduleUnitPriceYen(headcount);
    final fullSetUnitPrice = SubscriptionService.fullSetUnitPriceYen(headcount);

    return Scaffold(
      appBar: AppBar(title: const Text('モジュールを追加')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.module.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(widget.module.description),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                title: const Text('このモジュールのみ追加'),
                subtitle: Text('月額 ¥$moduleUnitPrice / 人'),
                trailing: FilledButton(
                  onPressed: _isProcessing ? null : () => _purchase(fullSet: false),
                  child: const Text('追加する'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                title: const Text('全カテゴリセット（おすすめ）'),
                subtitle: Text('月額 ¥$fullSetUnitPrice / 人（全6カテゴリ利用可）'),
                trailing: FilledButton(
                  onPressed: _isProcessing ? null : () => _purchase(fullSet: true),
                  child: const Text('セットで契約'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
