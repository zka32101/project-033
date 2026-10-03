import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/module_recommender.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/company_profile.dart';
import '../../../data/models/industry_model.dart';
import '../../../data/models/module_model.dart';
import '../../../data/seed/compliance_checklist_seed.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import '../company_profile/company_profile_input_screen.dart';

/// 受講コンテンツの設定。会社の規模・事業の特徴から推奨の研修をあらかじめチェックしておき、
/// 管理者は外す/足すだけで済むようにする。チェックした研修が、社員にとっての「必須」になる。
class ModuleAssignmentScreen extends ConsumerStatefulWidget {
  /// trueなら、保存済みの選択ではなく、現在の会社情報にもとづく推奨で選び直す。
  final bool applyRecommendation;

  const ModuleAssignmentScreen({super.key, this.applyRecommendation = false});

  @override
  ConsumerState<ModuleAssignmentScreen> createState() => _ModuleAssignmentScreenState();
}

class _Loaded {
  final Industry industry;
  final List<Module> modules;
  const _Loaded(this.industry, this.modules);
}

class _ModuleAssignmentScreenState extends ConsumerState<ModuleAssignmentScreen> {
  late Future<_Loaded> _future;
  Set<String>? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Loaded> _load() async {
    final company = ref.read(sessionProvider).company!;
    final content = ref.read(contentServiceProvider);
    final industry = await content.getIndustry(company.industryId);
    if (industry == null) throw StateError('業種が見つかりません');
    final modules = await content.listModulesForIndustry(
      industry,
      categoryPriorityOverride: company.categoryPriorityOverride,
      companyId: company.id,
    );
    return _Loaded(industry, modules);
  }

  CompanyProfile _profile() {
    final company = ref.read(sessionProvider).company!;
    return company.profile ?? CompanyProfile(employeeCount: company.contractedHeadcount);
  }

  Map<String, ModuleRecommendation> _recommend(_Loaded data) {
    final company = ref.read(sessionProvider).company!;
    return ModuleRecommender.recommend(
      modules: data.modules,
      industry: data.industry,
      profile: _profile(),
      checklistItems: seedComplianceItems,
      categoryPriorityOverride: company.categoryPriorityOverride,
    );
  }

  Future<void> _toggle(String moduleId, bool value, ModuleRecommendation rec) async {
    if (!value && rec.level == RecommendationLevel.required) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('必須の研修を外しますか?'),
          content: Text('この研修は、次の理由で必須と判定されています。\n\n${rec.reasons.take(3).join('\n')}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('残す')),
            FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('外す')),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() {
      if (value) {
        _selected!.add(moduleId);
      } else {
        _selected!.remove(moduleId);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final company = ref.read(sessionProvider).company!;
      final ids = _selected!.toList()..sort();
      await ref
          .read(companyServiceProvider)
          .updateAssignedModules(companyId: company.id, moduleIds: ids);
      ref.read(sessionProvider.notifier).updateCompany(company.copyWith(assignedModuleIds: ids));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('受講対象の研修(${ids.length}件)を保存しました')),
      );
      setState(() => _saving = false);
      Navigator.of(context).maybePop();
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
    return Scaffold(
      appBar: AppBar(title: const Text('受講コンテンツの設定')),
      body: FutureBuilder<_Loaded>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorRetryView(
              message: '研修の読み込みに失敗しました',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          final recs = _recommend(data);
          final preselected = ModuleRecommender.preselectedIds(recs);
          // 初回(保存済みの指定なし)または再推奨の指定なら、推奨をあらかじめチェックする。
          _selected ??= (widget.applyRecommendation || company.assignedModuleIds == null)
              ? {...preselected}
              : {...company.assignedModuleIds!.where(recs.containsKey)};
          final selected = _selected!;
          final theme = Theme.of(context);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    if (company.profile == null)
                      MaterialBanner(
                        content: const Text('会社情報が未入力です。入力すると、規模や事業に合った研修を自動で選べます。'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const CompanyProfileInputScreen()),
                            ),
                            child: const Text('入力する'),
                          ),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '推奨の研修をあらかじめチェックしています。不要なものは外し、必要なものを足してください。'
                        'チェックした研修が、社員の「必須」になります。',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('選択中: ${selected.length}件 / 全${data.modules.length}件',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          TextButton.icon(
                            onPressed: () => setState(() => _selected = {...preselected}),
                            icon: const Icon(Icons.auto_fix_high, size: 18),
                            label: const Text('推奨に戻す'),
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const CompanyProfileInputScreen()),
                            ),
                            icon: const Icon(Icons.tune, size: 18),
                            label: const Text('会社情報を変更'),
                          ),
                        ],
                      ),
                    ),
                    for (final category in [...Category.all]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
                      ..._categorySection(context, category, data.modules, recs, selected),
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
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text('この内容で保存する(${selected.length}件)'),
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

  List<Widget> _categorySection(
    BuildContext context,
    Category category,
    List<Module> modules,
    Map<String, ModuleRecommendation> recs,
    Set<String> selected,
  ) {
    final inCategory = modules.where((m) => m.categoryId == category.id).toList();
    if (inCategory.isEmpty) return const [];
    final chosen = inCategory.where((m) => selected.contains(m.id)).length;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text('${category.name}  $chosen/${inCategory.length}',
            style: Theme.of(context).textTheme.titleSmall),
      ),
      for (final m in inCategory)
        _ModuleTile(
          module: m,
          rec: recs[m.id]!,
          checked: selected.contains(m.id),
          onChanged: (v) => _toggle(m.id, v, recs[m.id]!),
        ),
    ];
  }
}

class _ModuleTile extends StatelessWidget {
  final Module module;
  final ModuleRecommendation rec;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _ModuleTile({
    required this.module,
    required this.rec,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final badge = switch (rec.level) {
      RecommendationLevel.required => ('必須', scheme.errorContainer, scheme.onErrorContainer),
      RecommendationLevel.recommended => ('推奨', scheme.primaryContainer, scheme.onPrimaryContainer),
      RecommendationLevel.optional => null,
    };
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      value: checked,
      onChanged: (v) => onChanged(v ?? false),
      title: Row(
        children: [
          if (badge != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: badge.$2, borderRadius: BorderRadius.circular(4)),
              child: Text(badge.$1, style: TextStyle(fontSize: 11, color: badge.$3)),
            ),
          Expanded(child: Text(module.title, style: const TextStyle(fontSize: 14))),
        ],
      ),
      subtitle: rec.reasons.isEmpty
          ? null
          : Text(rec.reasons.take(2).join('\n'), style: const TextStyle(fontSize: 11)),
    );
  }
}
