import 'package:cloud_functions/cloud_functions.dart';
import '../admin/company_profile/company_profile_input_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/company_model.dart';
import '../../data/models/employee_model.dart';
import '../../providers/industry_provider.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../dashboard/app_shell.dart';

/// 個人登録者向けの業種選択画面(チーム参加者は会社側で選択済みのためスキップ)
class IndustrySelectionScreen extends ConsumerStatefulWidget {
  final String individualDisplayName;

  const IndustrySelectionScreen({super.key, required this.individualDisplayName});

  @override
  ConsumerState<IndustrySelectionScreen> createState() =>
      _IndustrySelectionScreenState();
}

class _IndustrySelectionScreenState
    extends ConsumerState<IndustrySelectionScreen> {
  bool _isCreating = false;

  Future<void> _selectIndustry(String industryId) async {
    setState(() => _isCreating = true);
    try {
      final employeeService = ref.read(employeeServiceProvider);

      // employees.role=='admin'での作成はFirestoreルール上クライアント直接書き込みが
      // 禁止されている(自己昇格防止)ため、Cloud Functions経由でまとめて登録する。
      await employeeService.ensureAuthUid();

      final callable =
          FirebaseFunctions.instance.httpsCallable('registerCompanyAdmin');
      final result = await callable.call<Map<String, dynamic>>({
        'companyName': '${widget.individualDisplayName}さんのお試しチーム',
        'industryId': industryId,
        'planType': 'trial',
        'contractedHeadcount': 5,
        'adminDisplayName': widget.individualDisplayName,
      });
      final data = Map<String, dynamic>.from(result.data as Map);

      final company = Company(
        id: data['companyId'] as String,
        name: '${widget.individualDisplayName}さんのお試しチーム',
        industryId: industryId,
        planType: PlanType.trial,
        contractedHeadcount: (data['contractedHeadcount'] as num?)?.toInt() ?? 5,
        customPassThreshold: const {},
        createdAt: DateTime.now(),
        trialEndsAt: data['trialEndsAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch((data['trialEndsAt'] as num).toInt()),
      );
      final employee = Employee(
        id: data['employeeId'] as String,
        companyId: company.id,
        teamId: data['teamId'] as String? ?? '',
        displayName: widget.individualDisplayName,
        role: EmployeeRole.admin,
        createdAt: DateTime.now(),
      );

      ref.read(sessionProvider.notifier).signIn(
            employee: employee,
            company: company,
          );

      try {
        await ref.read(pushNotificationServiceProvider).registerToken(
              companyId: company.id,
              employeeId: employee.id,
            );
      } catch (_) {
        // プッシュ通知トークン登録の失敗はサインイン自体を妨げない。
      }

      if (!mounted) return;
      // InviteEntryScreenまで含めて戻れないようにする(戻ると別アカウントで再登録できてしまうため)。
      final navigator = Navigator.of(context);
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
      // 続けて、規模・事業の特徴を入力してもらい、必要な研修を自動で選ぶ。
      navigator.push(MaterialPageRoute(builder: (_) => const CompanyProfileInputScreen()));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登録に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final industriesAsync = ref.watch(industryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('業種を選択してください')),
      body: _isCreating
          ? const Center(child: CircularProgressIndicator())
          : industriesAsync.when(
              data: (industries) => ListView.builder(
                itemCount: industries.length,
                itemBuilder: (context, index) {
                  final industry = industries[index];
                  return ListTile(
                    title: Text(industry.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectIndustry(industry.id),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('読み込みに失敗しました: $err')),
            ),
    );
  }
}
