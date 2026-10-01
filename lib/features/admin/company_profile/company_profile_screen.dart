import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/employee_model.dart';
import '../../../providers/industry_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../dashboard/app_shell.dart';
import 'company_profile_input_screen.dart';

/// 管理者側の入口: 会社プロファイル設定(業種・企業名)→本社チーム作成→招待コード発行。
/// 従業員数や事業の特徴は、登録直後の会社情報の設定画面で入力する。
/// 登録は必ずお試し(14日・最大5名)で始まり、有料化は契約(決済)後にサーバーが行う。
class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() =>
      _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _companyNameController = TextEditingController();
  final _adminNameController = TextEditingController();
  String? _selectedIndustryId;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _companyNameController.dispose();
    _adminNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final companyName = _companyNameController.text.trim();
    final adminName = _adminNameController.text.trim();

    if (companyName.isEmpty || adminName.isEmpty || _selectedIndustryId == null) {
      setState(() => _errorMessage = '全ての項目を入力してください');
      return;
    }

    // 登録前に、会社名の入力内容を確認してもらう(誤入力のまま登録されるのを防ぐ)。
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('この会社名で登録しますか'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(companyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Text('管理者名: $adminName'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('修正する'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('登録する'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // employees.role=='admin'での作成はFirestoreルール上クライアント直接書き込みが
      // 禁止されている(自己昇格防止)ため、Cloud Functions経由でまとめて登録する。
      await ref.read(employeeServiceProvider).ensureAuthUid();

      final callable =
          FirebaseFunctions.instance.httpsCallable('registerCompanyAdmin');
      final result = await callable.call<Map<String, dynamic>>({
        'companyName': companyName,
        'industryId': _selectedIndustryId!,
        'adminDisplayName': adminName,
        'teamName': '本社',
      });
      final data = Map<String, dynamic>.from(result.data as Map);

      final company = Company(
        id: data['companyId'] as String,
        name: companyName,
        industryId: _selectedIndustryId!,
        planType: PlanType.trial,
        contractedHeadcount: (data['contractedHeadcount'] as num?)?.toInt() ?? 5,
        customPassThreshold: const {},
        createdAt: DateTime.now(),
        trialEndsAt: data['trialEndsAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch((data['trialEndsAt'] as num).toInt()),
      );
      final admin = Employee(
        id: data['employeeId'] as String,
        companyId: company.id,
        teamId: data['teamId'] as String? ?? '',
        displayName: adminName,
        role: EmployeeRole.admin,
        createdAt: DateTime.now(),
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
      final navigator = Navigator.of(context);
      navigator.pushAndRemoveUntil(
        // 管理者も研修の受講対象のため、受講者と同じホーム(AppShell)から開始する。
        // 管理メニューはホーム・アカウントから開ける。
        MaterialPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
      // 続けて、規模・事業の特徴を入力してもらい、必要な研修を自動で選ぶ。
      navigator.push(MaterialPageRoute(builder: (_) => const CompanyProfileInputScreen()));
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
