import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/compliance_item.dart';
import '../../../data/seed/compliance_checklist_seed.dart';
import '../../../data/seed/modules_seed.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';

/// 会社が実施すべきこと(届出・規程・選任・記録など)を、従業員数に応じて確認・記録する管理者向けチェックリスト。
class ComplianceChecklistScreen extends ConsumerStatefulWidget {
  const ComplianceChecklistScreen({super.key});

  @override
  ConsumerState<ComplianceChecklistScreen> createState() => _ComplianceChecklistScreenState();
}

class _ComplianceChecklistScreenState extends ConsumerState<ComplianceChecklistScreen> {
  bool _showUpcoming = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final company = session.company;
    if (!session.isSignedIn || !session.isAdmin || company == null) {
      return const Scaffold(body: Center(child: Text('管理者のみ利用できます')));
    }
    final headcount = company.legalEmployeeCount;
    final traits = company.profile?.traits;
    final service = ref.watch(complianceChecklistServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('法令対応チェックリスト')),
      body: StreamBuilder<Map<String, bool>>(
        stream: service.watchStatuses(company.id),
        builder: (context, snapshot) {
          final done = snapshot.data ?? const <String, bool>{};
          final applicable = seedComplianceItems.where((i) => i.appliesTo(headcount, traits: traits)).toList();
          final mandatory = applicable.where((i) => i.isMandatory).toList();
          final doneCount = mandatory.where((i) => done[i.id] == true).length;
          final visible = _showUpcoming ? seedComplianceItems : applicable;

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Summary(
                headcount: headcount,
                doneCount: doneCount,
                total: mandatory.length,
              ),
              SwitchListTile(
                title: const Text('人数が増えたら対象になる項目も表示'),
                subtitle: Text('現在の規模・事業内容では対象外の項目'),
                value: _showUpcoming,
                onChanged: (v) => setState(() => _showUpcoming = v),
              ),
              for (final category in ComplianceCategory.values) ...[
                if (visible.any((i) => i.category == category))
                  _CategoryHeader(label: category.label),
                for (final item in visible.where((i) => i.category == category))
                  _ItemTile(
                    item: item,
                    applicable: item.appliesTo(headcount, traits: traits),
                    checked: done[item.id] == true,
                    onChanged: (value) => service.setDone(
                      companyId: company.id,
                      itemId: item.id,
                      done: value,
                    ),
                  ),
              ],
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text(
                  'このチェックリストは一般的な目安です。実際に適用される義務は、事業の内容や雇用の形態によって異なります。'
                  '数値や期限は最新の情報を確認し、必要に応じて社会保険労務士などの専門家に相談してください。',
                  style: TextStyle(fontSize: 12, height: 1.6),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int headcount;
  final int doneCount;
  final int total;

  const _Summary({required this.headcount, required this.doneCount, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : doneCount / total;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('従業員 $headcount名の事業場の実施状況', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text('義務の項目 $doneCount / $total 完了',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: ratio, minHeight: 8),
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String label;

  const _CategoryHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final ComplianceItem item;
  final bool applicable;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _ItemTile({
    required this.item,
    required this.applicable,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final moduleTitles = seedModules
        .where((m) => item.relatedModuleIds.contains(m.id))
        .map((m) => m.title)
        .toList();
    return Opacity(
      opacity: applicable ? 1 : 0.55,
      child: ExpansionTile(
        leading: Checkbox(
          value: checked,
          onChanged: applicable ? (v) => onChanged(v ?? false) : null,
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Wrap(
          spacing: 6,
          children: [
            _Tag(
              label: item.isMandatory ? '義務' : '推奨',
              color: item.isMandatory ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
            ),
            if (!applicable) _Tag(label: '${item.minHeadcount}人以上で対象', color: colorScheme.tertiaryContainer),
            if (item.condition != null) _Tag(label: '条件あり', color: colorScheme.secondaryContainer),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.description, style: const TextStyle(height: 1.6)),
          if (item.condition != null) ...[
            const SizedBox(height: 8),
            Text('対象となる場合: ${item.condition}', style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(height: 8),
          Text('根拠: ${item.law}', style: TextStyle(fontSize: 12, color: colorScheme.outline)),
          if (moduleTitles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('関連する研修', style: TextStyle(fontSize: 12, color: colorScheme.outline)),
            for (final t in moduleTitles) Text('・$t', style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
