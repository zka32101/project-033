import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/module_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import '../../../widgets/skeleton_loader.dart';

/// 合格ライン設定画面(設計書 データモデル: Company.customPassThreshold)。
/// 企業規模による推奨値を表示しつつ、モジュール単位で合格ラインを上書きできる。
class PassThresholdSettingsScreen extends ConsumerStatefulWidget {
  const PassThresholdSettingsScreen({super.key});

  @override
  ConsumerState<PassThresholdSettingsScreen> createState() =>
      _PassThresholdSettingsScreenState();
}

class _PassThresholdSettingsScreenState
    extends ConsumerState<PassThresholdSettingsScreen> {
  late Future<List<Module>> _modulesFuture;
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _saving = {};

  @override
  void initState() {
    super.initState();
    final company = ref.read(sessionProvider).company!;
    _modulesFuture = ref
        .read(contentServiceProvider)
        .getIndustry(company.industryId)
        .then((industry) {
      if (industry == null) return <Module>[];
      return ref.read(contentServiceProvider).listModulesForIndustry(industry);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String moduleId, int initialValue) {
    return _controllers.putIfAbsent(
      moduleId,
      () => TextEditingController(text: initialValue.toString()),
    );
  }

  Future<void> _save(String moduleId) async {
    final text = _controllers[moduleId]?.text.trim() ?? '';
    final value = int.tryParse(text);
    if (value == null || value < 0 || value > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('0〜100の数値を入力してください')),
      );
      return;
    }
    final company = ref.read(sessionProvider).company!;
    setState(() => _saving.add(moduleId));
    try {
      await ref.read(companyServiceProvider).updateModulePassThreshold(
            companyId: company.id,
            moduleId: moduleId,
            threshold: value,
          );
      ref.read(sessionProvider.notifier).updateCompany(
            company.copyWith(
              customPassThreshold: {
                ...company.customPassThreshold,
                moduleId: value,
              },
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('合格ラインを更新しました')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(moduleId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final company = session.company!;
    final recommended = company.recommendedPassThreshold();

    return Scaffold(
      appBar: AppBar(title: const Text('合格ライン設定')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '契約人数(${company.contractedHeadcount}名)からの推奨合格ラインは$recommended%です。'
              'モジュールごとに個別の合格ラインを設定できます。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Module>>(
              future: _modulesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const ErrorRetryView(message: 'モジュール一覧の読み込みに失敗しました');
                }
                if (!snapshot.hasData) {
                  return const SkeletonList();
                }
                final modules = snapshot.data!;
                return ListView.builder(
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    final current = company.passThresholdFor(
                      module.id,
                      moduleDefault: module.passThresholdDefault,
                    );
                    final isCustom = company.customPassThreshold.containsKey(module.id);
                    final controller = _controllerFor(module.id, current);
                    final isSaving = _saving.contains(module.id);

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
                                    module.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (isCustom)
                                  Chip(
                                    label: const Text('個別設定中'),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primaryContainer,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      suffixText: '%',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: isSaving ? null : () => _save(module.id),
                                  child: isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('保存'),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '推奨: $recommended%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
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
