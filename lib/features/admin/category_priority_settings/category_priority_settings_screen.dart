import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/industry_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import '../../../widgets/skeleton_loader.dart';

const _priorityLabels = {2: '高', 1: '中', 0: '低'};

/// 業種プロファイル手動調整UI(設計書 Section3の優先度テーブルを会社ごとに上書き)。
/// 業種の初期値はあくまで一般的な目安のため、実際の重点分野に合わせて調整できるようにする。
class CategoryPrioritySettingsScreen extends ConsumerStatefulWidget {
  const CategoryPrioritySettingsScreen({super.key});

  @override
  ConsumerState<CategoryPrioritySettingsScreen> createState() =>
      _CategoryPrioritySettingsScreenState();
}

class _CategoryPrioritySettingsScreenState
    extends ConsumerState<CategoryPrioritySettingsScreen> {
  late Future<Industry?> _industryFuture;
  final Set<String> _saving = {};

  @override
  void initState() {
    super.initState();
    final company = ref.read(sessionProvider).company!;
    _industryFuture = ref.read(contentServiceProvider).getIndustry(company.industryId);
  }

  Future<void> _updatePriority(String categoryId, int priority) async {
    final company = ref.read(sessionProvider).company!;
    setState(() => _saving.add(categoryId));
    try {
      await ref.read(companyServiceProvider).updateCategoryPriorityOverride(
            companyId: company.id,
            categoryId: categoryId,
            priority: priority,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(categoryId));
    }
  }

  Future<void> _resetToDefault(String categoryId) async {
    final company = ref.read(sessionProvider).company!;
    setState(() => _saving.add(categoryId));
    try {
      await ref.read(companyServiceProvider).clearCategoryPriorityOverride(
            companyId: company.id,
            categoryId: categoryId,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(categoryId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final company = session.company!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('業種プロファイル調整')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '業種の初期優先度を、実際の重点分野に合わせて会社ごとに調整できます。'
              '優先度が高いカテゴリのモジュールほど社員のホーム画面上位に表示されます。',
              style: TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            child: FutureBuilder<Industry?>(
              future: _industryFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const ErrorRetryView(message: '業種情報の読み込みに失敗しました');
                }
                if (!snapshot.hasData) {
                  return const SkeletonList();
                }
                final industry = snapshot.data;
                if (industry == null) {
                  return const Center(child: Text('業種情報が見つかりませんでした'));
                }

                return ListView.builder(
                  itemCount: Category.all.length,
                  itemBuilder: (context, index) {
                    final category = Category.all[index];
                    final categoryKey = category.id.name;
                    final defaultPriority = industry.priorityOf(category.id);
                    final currentPriority =
                        company.categoryPriorityOverride[categoryKey] ?? defaultPriority;
                    final isOverridden =
                        company.categoryPriorityOverride.containsKey(categoryKey);
                    final isSaving = _saving.contains(categoryKey);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (isOverridden)
                                  Chip(
                                    label: const Text('個別設定中'),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: colorScheme.primaryContainer,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SegmentedButton<int>(
                                    segments: const [
                                      ButtonSegment(value: 2, label: Text('高')),
                                      ButtonSegment(value: 1, label: Text('中')),
                                      ButtonSegment(value: 0, label: Text('低')),
                                    ],
                                    selected: {currentPriority},
                                    onSelectionChanged: isSaving
                                        ? null
                                        : (selection) =>
                                            _updatePriority(categoryKey, selection.first),
                                  ),
                                ),
                                if (isOverridden) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.restart_alt),
                                    tooltip: '業種初期値(${_priorityLabels[defaultPriority]})に戻す',
                                    onPressed:
                                        isSaving ? null : () => _resetToDefault(categoryKey),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
