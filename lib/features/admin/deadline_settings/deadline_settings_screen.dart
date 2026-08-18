import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/module_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import '../../../widgets/skeleton_loader.dart';

/// 受講期限設定画面。モジュールごとに期限日を設定し、期限が近づく/過ぎた社員には
/// (Cloud Functions側の定期チェックにより)自動でプッシュ通知が送られる想定。
class DeadlineSettingsScreen extends ConsumerStatefulWidget {
  const DeadlineSettingsScreen({super.key});

  @override
  ConsumerState<DeadlineSettingsScreen> createState() => _DeadlineSettingsScreenState();
}

class _DeadlineSettingsScreenState extends ConsumerState<DeadlineSettingsScreen> {
  late Future<List<Module>> _modulesFuture;
  final Set<String> _saving = {};
  final _dateFormat = DateFormat('yyyy/MM/dd');

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

  Future<void> _pickDate(String moduleId, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;

    final company = ref.read(sessionProvider).company!;
    setState(() => _saving.add(moduleId));
    try {
      await ref.read(companyServiceProvider).updateModuleDeadline(
            companyId: company.id,
            moduleId: moduleId,
            dueDate: picked,
          );
      ref.read(sessionProvider.notifier).updateCompany(
            company.copyWith(
              moduleDeadlines: {...company.moduleDeadlines, moduleId: picked},
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('期限を設定しました')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('設定に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(moduleId));
    }
  }

  Future<void> _clearDeadline(String moduleId) async {
    final company = ref.read(sessionProvider).company!;
    setState(() => _saving.add(moduleId));
    try {
      await ref.read(companyServiceProvider).clearModuleDeadline(
            companyId: company.id,
            moduleId: moduleId,
          );
      final updatedDeadlines = {...company.moduleDeadlines}..remove(moduleId);
      ref.read(sessionProvider.notifier).updateCompany(
            company.copyWith(moduleDeadlines: updatedDeadlines),
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('解除に失敗しました。時間をおいて再度お試しください')),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('受講期限設定')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '期限が近づいた社員・過ぎた社員には自動でプッシュ通知が送信されます'
              '(Firebase Cloud Functions設定完了後に有効化)。',
              style: TextStyle(fontSize: 12),
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
                    final deadline = company.deadlineFor(module.id);
                    final isSaving = _saving.contains(module.id);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    module.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    deadline != null
                                        ? '期限: ${_dateFormat.format(deadline)}'
                                        : '期限未設定',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: deadline != null
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSaving)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            else ...[
                              TextButton(
                                onPressed: () => _pickDate(module.id, deadline),
                                child: Text(deadline != null ? '変更' : '設定'),
                              ),
                              if (deadline != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  tooltip: '期限を解除',
                                  onPressed: () => _clearDeadline(module.id),
                                ),
                            ],
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
