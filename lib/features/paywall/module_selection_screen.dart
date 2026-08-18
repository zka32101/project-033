import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/models/industry_model.dart';
import '../../data/models/module_model.dart';
import '../../data/models/subscription_model.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../../services/subscription_service.dart';
import '../../widgets/error_retry_view.dart';
import '../../widgets/skeleton_loader.dart';

/// 上位プランでのモジュール選択画面(設計書: 利用者数に応じた課金体系＋
/// カテゴリ(分類)ごとに中項目(モジュール)単位で対象/対象外を選択できる)。
/// 基本プランへの切り替えもここから行う。
class ModuleSelectionScreen extends ConsumerStatefulWidget {
  /// ロックされたモジュールをタップして遷移した場合、そのモジュールIDを事前選択する。
  final String? preselectModuleId;

  const ModuleSelectionScreen({super.key, this.preselectModuleId});

  @override
  ConsumerState<ModuleSelectionScreen> createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends ConsumerState<ModuleSelectionScreen> {
  late Future<(Industry?, List<Module>)> _dataFuture;
  ModulePlanTier _planTier = ModulePlanTier.basic;
  final Set<String> _selectedModuleIds = {};
  bool _isSaving = false;
  bool _initializedFromExisting = false;

  @override
  void initState() {
    super.initState();
    final company = ref.read(sessionProvider).company!;
    _dataFuture = ref
        .read(contentServiceProvider)
        .getIndustry(company.industryId)
        .then((industry) async {
      if (industry == null) return (industry, <Module>[]);
      final modules =
          await ref.read(contentServiceProvider).listModulesForIndustry(industry);
      return (industry, modules);
    });
    _loadExistingSubscription();
    if (widget.preselectModuleId != null) {
      _selectedModuleIds.add(widget.preselectModuleId!);
      _planTier = ModulePlanTier.upper;
    }
  }

  Future<void> _loadExistingSubscription() async {
    final company = ref.read(sessionProvider).company!;
    final subscription = await ref.read(subscriptionServiceProvider).getActiveSubscription(
          companyId: company.id,
          ownerType: SubscriptionOwnerType.company,
          ownerId: company.id,
        );
    if (!mounted || _initializedFromExisting) return;
    _initializedFromExisting = true;
    setState(() {
      if (subscription != null) {
        _planTier = widget.preselectModuleId != null
            ? ModulePlanTier.upper
            : subscription.planTier;
        _selectedModuleIds.addAll(subscription.subscribedModuleIds);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final session = ref.read(sessionProvider);
      final company = session.company!;
      final subscription = await ref.read(subscriptionServiceProvider).upsertSubscription(
            companyId: company.id,
            ownerType: SubscriptionOwnerType.company,
            ownerId: company.id,
            subscribedModuleIds: _selectedModuleIds.toList(),
            fullSet: false,
            headcount: company.contractedHeadcount,
            planTier: _planTier,
          );
      await ref.read(analyticsServiceProvider).logSubscriptionUpgraded(
            companyId: company.id,
            planTier: subscription.planTier,
            moduleCount: subscription.subscribedModuleIds.length,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('契約処理に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(sessionProvider).company!;
    final colorScheme = Theme.of(context).colorScheme;
    final unitPrice = SubscriptionService.planUnitPriceYen(_planTier, company.contractedHeadcount);
    final monthlyPrice = SubscriptionService.monthlyPriceYen(
      headcount: company.contractedHeadcount,
      planTier: _planTier,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('受講プラン設定')),
      body: FutureBuilder<(Industry?, List<Module>)>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorRetryView(message: '業種情報の読み込みに失敗しました');
          }
          if (!snapshot.hasData) {
            return const SkeletonList();
          }
          final (industry, modules) = snapshot.data!;
          if (industry == null) {
            return const Center(child: Text('業種情報が見つかりませんでした'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<ModulePlanTier>(
                segments: const [
                  ButtonSegment(value: ModulePlanTier.basic, label: Text('基本プラン')),
                  ButtonSegment(value: ModulePlanTier.upper, label: Text('上位プラン')),
                ],
                selected: {_planTier},
                onSelectionChanged: (selection) =>
                    setState(() => _planTier = selection.first),
              ),
              const SizedBox(height: 16),
              Card(
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '契約人数(${company.contractedHeadcount}名) × ¥$unitPrice/人',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '月額 ¥$monthlyPrice',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _planTier == ModulePlanTier.basic
                            ? '各カテゴリの無料体験モジュールのみ利用できます(モジュール選択不可)'
                            : '選択したモジュール数に関わらず月額は変わりません',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_planTier == ModulePlanTier.upper) ...[
                Text(
                  'カテゴリごとに対象にするモジュールを選んでください',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                for (final category in Category.all)
                  _buildCategorySection(category, modules),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存する'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategorySection(Category category, List<Module> modules) {
    final categoryModules =
        modules.where((m) => m.categoryId == category.id).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (categoryModules.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            for (final module in categoryModules)
              CheckboxListTile(
                value: module.isFreeTrial || _selectedModuleIds.contains(module.id),
                onChanged: module.isFreeTrial
                    ? null
                    : (checked) => setState(() {
                          if (checked ?? false) {
                            _selectedModuleIds.add(module.id);
                          } else {
                            _selectedModuleIds.remove(module.id);
                          }
                        }),
                title: Text(module.title),
                subtitle: module.isFreeTrial ? const Text('無料体験(常に利用可)') : null,
                dense: true,
              ),
          ],
        ),
      ),
    );
  }
}
