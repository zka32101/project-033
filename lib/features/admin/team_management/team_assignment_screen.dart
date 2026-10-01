import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/module_model.dart';
import '../../../data/models/team_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';

/// チーム別の必須研修の設定。全社共通の必須に加えて、このチームだけ必須にする研修を選ぶ
/// (例: 営業チームだけ景品表示法、経理チームだけインボイス制度)。全社共通の必須は変更できない。
class TeamModuleAssignmentScreen extends ConsumerStatefulWidget {
  final Team team;

  const TeamModuleAssignmentScreen({super.key, required this.team});

  @override
  ConsumerState<TeamModuleAssignmentScreen> createState() => _TeamModuleAssignmentScreenState();
}

class _TeamModuleAssignmentScreenState extends ConsumerState<TeamModuleAssignmentScreen> {
  late Future<List<Module>> _future;
  late final Set<String> _extra;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _extra = {...widget.team.assignedModuleIds};
    _future = _load();
  }

  Future<List<Module>> _load() async {
    final company = ref.read(sessionProvider).company!;
    final content = ref.read(contentServiceProvider);
    final industry = await content.getIndustry(company.industryId);
    if (industry == null) throw StateError('業種が見つかりません');
    return content.listModulesForIndustry(
      industry,
      categoryPriorityOverride: company.categoryPriorityOverride,
    );
  }

  Future<void> _save(Set<String> commonIds) async {
    setState(() => _saving = true);
    try {
      final company = ref.read(sessionProvider).company!;
      // 全社共通の必須は、チームの追加分には含めない(重複して保存しない)。
      final ids = (_extra.difference(commonIds).toList())..sort();
      await ref.read(companyServiceProvider).updateTeamAssignedModules(
            companyId: company.id,
            teamId: widget.team.id,
            moduleIds: ids,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.team.teamName}の追加の必須研修(${ids.length}件)を保存しました')),
      );
      setState(() => _saving = false);
      Navigator.of(context).maybePop(ids);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存に失敗しました。時間をおいてお試しください')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(sessionProvider).company!;
    final common = (company.assignedModuleIds ?? const <String>[]).toSet();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.team.teamName}の必須研修')),
      body: FutureBuilder<List<Module>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorRetryView(
              message: '研修の読み込みに失敗しました',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final modules = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '全社共通の必須に加えて、このチームだけ必須にする研修を選びます。'
                        '全社共通の必須(グレー)は、「受講コンテンツの設定」で変更できます。',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (company.assignedModuleIds == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '全社の受講対象が未設定のため、業種の重点分野が必須になっています。',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        'このチームの追加: ${_extra.difference(common).length}件',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    for (final category in [...Category.all]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
                      ..._section(context, category, modules, common),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : () => _save(common),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('この内容で保存する'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _section(BuildContext context, Category category, List<Module> modules, Set<String> common) {
    final inCategory = modules.where((m) => m.categoryId == category.id).toList();
    if (inCategory.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(category.name, style: Theme.of(context).textTheme.titleSmall),
      ),
      for (final m in inCategory)
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: common.contains(m.id) || _extra.contains(m.id),
          // 全社共通の必須は、ここでは外せない。
          onChanged: common.contains(m.id)
              ? null
              : (v) => setState(() {
                    if (v == true) {
                      _extra.add(m.id);
                    } else {
                      _extra.remove(m.id);
                    }
                  }),
          title: Text(m.title, style: const TextStyle(fontSize: 14)),
          subtitle: common.contains(m.id) ? const Text('全社共通の必須', style: TextStyle(fontSize: 11)) : null,
        ),
    ];
  }
}
