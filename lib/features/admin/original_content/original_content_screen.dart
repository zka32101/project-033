import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/custom_module_model.dart';
import '../../../data/models/module_model.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../services/subscription_service.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/error_retry_view.dart';
import 'ai_content_generator_screen.dart';
import 'manual_content_editor_screen.dart';

/// オリジナルコンテンツ管理画面。
/// 自分で研修・問題を作る機能は、どのプランでも使える(管理者のみ)。AIによる下書き作成はプレミアムプラン(準備中)。
class OriginalContentScreen extends ConsumerStatefulWidget {
  const OriginalContentScreen({super.key});

  @override
  ConsumerState<OriginalContentScreen> createState() => _OriginalContentScreenState();
}

class _OriginalContentScreenState extends ConsumerState<OriginalContentScreen> {
  late Future<Subscription?> _subscriptionFuture;

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

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(sessionProvider).company!;

    return Scaffold(
      appBar: AppBar(title: const Text('オリジナル研修・問題')),
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
              Text('自分で作る', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '自社のルールや事例にあわせた研修・問題を作れます。どのプランでも使えます。作った研修は、必須研修にも選べます。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('create_manual'),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('研修を新しく作る'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ManualContentEditorScreen.create()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const ValueKey('extend_manual'),
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('既存の研修に追加'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ManualContentEditorScreen.extend()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('作成済みのオリジナル研修', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              StreamBuilder<List<CustomModule>>(
                stream: ref.read(customContentServiceProvider).watchCustomModules(company.id),
                builder: (context, moduleSnapshot) {
                  if (moduleSnapshot.hasError) {
                    return const ErrorRetryView(message: '研修一覧の読み込みに失敗しました');
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
                        message: 'まだオリジナル研修がありません',
                      ),
                    );
                  }
                  return Column(
                    children: modules
                        .map((m) => Card(
                              child: ListTile(
                                title: Text(m.title),
                                subtitle: Text(m.description),
                                trailing: const Icon(Icons.edit_outlined),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ManualContentEditorScreen.edit(module: m)),
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('既存の研修に追加した内容', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              FutureBuilder<List<Module>>(
                future: _loadExtendedModules(company.id, company.industryId),
                builder: (context, snap) {
                  if (snap.hasError) return const ErrorRetryView(message: '追加内容の読み込みに失敗しました');
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    );
                  }
                  if (snap.data!.isEmpty) return const Text('まだ追加した内容はありません');
                  return Column(
                    children: snap.data!
                        .map((m) => Card(
                              child: ListTile(
                                title: Text(m.title),
                                trailing: const Icon(Icons.edit_outlined),
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (_) => ManualContentEditorScreen.extend(targetModule: m)))
                                    .then((_) => setState(() {})),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const Divider(height: 40),
              Text('AIで下書きを作る(準備中)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildPlanCard(subscription, canExtend, canCreate),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('既存の研修にAIで追加'),
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
                      label: const Text('AIで新規作成'),
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
            ],
          );
        },
      ),
    );
  }

  /// 既存(グローバル)の研修のうち、会社が追加した内容があるもの。
  Future<List<Module>> _loadExtendedModules(String companyId, String industryId) async {
    final content = ref.read(contentServiceProvider);
    final ids = await ref.read(customContentServiceProvider).listExtendedModuleIds(companyId);
    if (ids.isEmpty) return const [];
    final industry = await content.getIndustry(industryId);
    if (industry == null) return const [];
    final modules = await content.listModulesForIndustry(industry);
    return modules.where((m) => ids.contains(m.id)).toList();
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
            const SizedBox(height: 12),
            const Text(
              'プレミアムプランのお申し込みは準備中です。ご利用をご希望の場合は、運営までお問い合わせください。',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            if (!canExtend)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('既存モジュール追加プラン'),
                subtitle: Text(
                  '月額 ¥${SubscriptionService.premiumTierMonthlyPriceYen(PremiumTier.moduleExtension)}(headcount: $headcount名)',
                ),
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('新規モジュール作成プラン(おすすめ)'),
              subtitle: Text(
                '月額 ¥${SubscriptionService.premiumTierMonthlyPriceYen(PremiumTier.moduleCreation)}(既存モジュール追加も含む)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
