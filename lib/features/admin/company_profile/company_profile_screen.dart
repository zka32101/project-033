import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/company_model.dart';
import '../../../providers/industry_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../team_management/team_management_screen.dart';

/// 管理者側の入口: 会社プロファイル設定(業種・企業名・契約人数)→本社チーム作成→招待コード発行
class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _companyNameController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _headcountController = TextEditingController(text: '20');
  String? _selectedIndustryId;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _companyNameController.dispose();
    _adminNameController.dispose();
    _headcountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final companyName = _companyNameController.text.trim();
    final adminName = _adminNameController.text.trim();
    final headcount = int.tryParse(_headcountController.text.trim()) ?? 0;

    if (companyName.isEmpty ||
        adminName.isEmpty ||
        _selectedIndustryId == null ||
        headcount <= 0) {
      setState(() => _errorMessage = '全ての項目を入力してください');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final company = await ref.read(companyServiceProvider).createCompany(
            name: companyName,
            industryId: _selectedIndustryId!,
            planType: PlanType.team,
            contractedHeadcount: headcount,
          );
      final team = await ref.read(inviteServiceProvider).createTeam(
            companyId: company.id,
            teamName: '本社',
          );
      final admin = await ref.read(employeeServiceProvider).createAdmin(
            companyId: company.id,
            teamId: team.id,
            displayName: adminName,
          );

      ref.read(sessionProvider.notifier).signIn(employee: admin, company: company);

      try {
        await ref.read(pushNotificationServiceProvider).registerToken(
              companyId: company.id,
              employeeId: admin.id,
            );
      } catch (_) {
        // プッシュ通知トークン登録の失敗はサインイン自体を妨げない。
      }

      if (!mounted) return;
      // InviteEntryScreenまで含めて戻れないようにする(戻ると別アカウントで再登録できてしまうため)。
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TeamManagementScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _errorMessage = '登録に失敗しました。時間をおいて再度お試しください');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final industriesAsync = ref.watch(industryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('会社プロファイル設定')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: '会社名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _adminNameController,
              decoration: const InputDecoration(
                labelText: '管理者のお名前',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _headcountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '契約人数',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            industriesAsync.when(
              data: (industries) => DropdownButtonFormField<String>(
                initialValue: _selectedIndustryId,
                decoration: const InputDecoration(
                  labelText: '業種',
                  border: OutlineInputBorder(),
                ),
                items: industries
                    .map((i) => DropdownMenuItem(value: i.id, child: Text(i.name)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedIndustryId = value),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('業種一覧の読み込みに失敗しました: $err'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('登録して開始する'),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
