import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/custom_module_model.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../services/subscription_service.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/error_retry_view.dart';
import 'ai_content_generator_screen.dart';

/// オリジナルコンテンツ管理画面(プレミアムプラン)。
/// 既存モジュールへのコンテンツ追加・新規オリジナルモジュール作成の入口となる。
class OriginalContentScreen extends ConsumerStatefulWidget {
  const OriginalContentScreen({super.key});

  @override
  ConsumerState<OriginalContentScreen> createState() => _OriginalContentScreenState();
}

class _OriginalContentScreenState extends ConsumerState<OriginalContentScreen> {
  late Future<Subscription?> _subscriptionFuture;
  bool _isUpgrading = false;

  @override
  void initState() {
    super.initState();
    _subscriptionFuture = _loadSubscription();
  }

  Future<Subscription?> _loadSubscription() {
    final company = ref.read(sessionProvider).company!;
    return ref.read(subscriptionServiceProvider).getActiveSubscription(
          companyId: company.id,
          ownerType: SubscriptionOwnerType.company,
          ownerId: company.id,
        );
  }

  Future<void> _upgrade(PremiumTier tier) async {
    setState(() => _isUpgrading = true);
    try {
      final company = ref.read(sessionProvider).company!;
      await ref.read(subscriptionServiceProvider).upsertPremiumTier(
            companyId: company.id,
            ownerType: SubscriptionOwnerType.company,
            ownerId: company.id,
            premiumTier: tier,
            headcount: company.contractedHeadcount,
          );
      setState(() => _subscriptionFuture = _loadSubscription());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('契約処理に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpgrading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(sessionProvider).company!;

    return Scaffold(
      appBar: AppBar(title: const Text('オリジナルコンテンツ管理')),
      body: FutureBuilder<Subscription?>(
        future: _subscriptionFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorRetryView(message: '契約情報の読み込みに失敗しました');
          }
          if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final subscription = snapshot.data;
          final canExtend = subscription?.canExtendExistingModules ?? false;
          final canCreate = subscription?.canCreateOriginalModules ?? false;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPlanCard(subscription, canExtend, canCreate),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('既存モジュールに追加'),
                      onPressed: canExtend
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AiContentGeneratorScreen(
                                    mode: ContentGenerationMode.extend,
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('新規モジュール作成'),
                      onPressed: canCreate
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AiContentGeneratorScreen(
                                    mode: ContentGenerationMode.create,
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('作成済みのオリジナルモジュール', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              StreamBuilder<List<CustomModule>>(
                stream: ref.read(customContentServiceProvider).watchCustomModules(company.id),
                builder: (context, moduleSnapshot) {
                  if (moduleSnapshot.hasError) {
                    return const ErrorRetryView(message: 'モジュール一覧の読み込みに失敗しました');
                  }
                  if (!moduleSnapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    );
                  }
                  final modules = moduleSnapshot.data!;
                  if (modules.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: EmptyStateView(
                        imagePath: 'assets/images/empty_states/empty_state_no_modules.png',
                        message: 'まだオリジナルモジュールがありません',
                      ),
                    );
                  }
                  return Column(
                    children: modules
                        .map((m) => Card(
                              child: ListTile(
                                title: Text(m.title),
                                subtitle: Text(m.description),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(Subscription? subscription, bool canExtend, bool canCreate) {
    final colorScheme = Theme.of(context).colorScheme;
    final headcount = ref.read(sessionProvider).company!.contractedHeadcount;

    if (canCreate) {
      return Card(
        color: colorScheme.primaryContainer,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('現在のプラン: 新規モジュール作成プラン(既存モジュール追加も利用できます)'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              canExtend ? '現在のプラン: 既存モジュール追加プラン' : 'プレミアムプラン未契約',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'AIがテーマからレッスン・クイズを自動生成します。自社の実情に合わせたオリジナル研修を作成できます。',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (!canExtend)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('既存モジュール追加プラン'),
                subtitle: Text(
                  '月額 ¥${SubscriptionService.premiumTierMonthlyPriceYen(PremiumTier.moduleExtension)}(headcount: $headcount名)',
                ),
                trailing: FilledButton(
                  onPressed: _isUpgrading
                      ? null
                      : () => _upgrade(PremiumTier.moduleExtension),
                  child: const Text('契約する'),
                ),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('新規モジュール作成プラン(おすすめ)'),
              subtitle: Text(
                '月額 ¥${SubscriptionService.premiumTierMonthlyPriceYen(PremiumTier.moduleCreation)}(既存モジュール追加も含む)',
              ),
              trailing: FilledButton(
                onPressed:
                    _isUpgrading ? null : () => _upgrade(PremiumTier.moduleCreation),
                child: const Text('契約する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
