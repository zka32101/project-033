import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/module_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';

/// 「全社共通の必須に加えて、追加で必須にする研修」を選ぶ画面(チーム別・職種別で共通)。
/// 全社共通の必須([lockedIds])は、ここでは外せない(グレー表示)。
class ExtraModulesScreen extends ConsumerStatefulWidget {
  final String title;
  final String intro;

  /// 「このチームの追加: N件」のような件数表示。
  final String Function(int count) countLabel;
  final List<String> initialIds;

  /// 保存。全社共通の必須を除いた、追加分のIDが渡される。
  final Future<void> Function(List<String> extraIds) onSave;
  final String Function(int count) savedMessage;

  const ExtraModulesScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.countLabel,
    required this.initialIds,
    required this.onSave,
    required this.savedMessage,
  });

  @override
  ConsumerState<ExtraModulesScreen> createState() => _ExtraModulesScreenState();
}

class _ExtraModulesScreenState extends ConsumerState<ExtraModulesScreen> {
  late Future<List<Module>> _future;
  late final Set<String> _extra;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _extra = {...widget.initialIds};
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
      companyId: company.id,
    );
  }

  Future<void> _save(Set<String> commonIds) async {
    setState(() => _saving = true);
    try {
      // 全社共通の必須は、追加分には含めない(重複して保存しない)。
      final ids = (_extra.difference(commonIds).toList())..sort();
      await widget.onSave(ids);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.savedMessage(ids.length))));
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
      appBar: AppBar(title: Text(widget.title)),
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
                      child: Text(widget.intro, style: theme.textTheme.bodyMedium),
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
                        widget.countLabel(_extra.difference(common).length),
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
