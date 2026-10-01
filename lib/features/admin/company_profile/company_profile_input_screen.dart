import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/company_profile.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../module_assignment/module_assignment_screen.dart';

/// 会社の規模・事業の特徴の入力。入力内容から、法令上必要な研修を自動で推奨する。
class CompanyProfileInputScreen extends ConsumerStatefulWidget {
  const CompanyProfileInputScreen({super.key});

  @override
  ConsumerState<CompanyProfileInputScreen> createState() => _CompanyProfileInputScreenState();
}

class _CompanyProfileInputScreenState extends ConsumerState<CompanyProfileInputScreen> {
  late final TextEditingController _countController;
  late final Set<BusinessTrait> _traits;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final company = ref.read(sessionProvider).company!;
    final profile = company.profile;
    _countController = TextEditingController(text: '${profile?.employeeCount ?? ''}');
    _traits = {...?profile?.traits};
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  int? get _count {
    final n = int.tryParse(_countController.text.trim());
    return (n != null && n >= 1 && n <= 1000000) ? n : null;
  }

  Future<void> _save() async {
    final count = _count;
    if (count == null) return;
    setState(() => _saving = true);
    try {
      final company = ref.read(sessionProvider).company!;
      final profile = CompanyProfile(employeeCount: count, traits: _traits);
      await ref.read(companyServiceProvider).updateProfile(companyId: company.id, profile: profile);
      ref.read(sessionProvider.notifier).updateCompany(company.copyWith(profile: profile));
      if (!mounted) return;
      // 入力内容にもとづく推奨を、あらかじめチェックした状態で確認してもらう。
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ModuleAssignmentScreen(applyRecommendation: true)),
      );
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
    final theme = Theme.of(context);
    final count = _count;
    return Scaffold(
      appBar: AppBar(title: const Text('会社情報の設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '規模と事業の特徴を入力すると、法令上必要な研修を自動で選びます。あとから変更もできます。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Text('従業員数', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '事業場の従業員数(パート・アルバイトを含む)',
              suffixText: '名',
              helperText: '10名・50名などの人数で、必要な手続きや研修が変わります',
              helperMaxLines: 2,
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Text('事業の特徴(当てはまるものを選んでください)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          for (final trait in BusinessTrait.values)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _traits.contains(trait),
              title: Text(trait.label),
              subtitle: Text(trait.hint, style: const TextStyle(fontSize: 12)),
              onChanged: (v) => setState(() {
                if (v == true) {
                  _traits.add(trait);
                } else {
                  _traits.remove(trait);
                }
              }),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: (count == null || _saving) ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('保存して、推奨の研修を確認する'),
          ),
          const SizedBox(height: 8),
          Text(
            '※ 推奨は一般的な目安です。実際に必要な手続き・研修は、事業の内容や契約形態で変わります。',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
