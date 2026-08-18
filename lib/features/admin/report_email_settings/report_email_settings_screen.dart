import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';

/// 月次レポート自動メール送信の送付先設定(設計書 Must③の運用補助)。
/// 毎月1日にCloud Functions(sendMonthlyReports)がここで設定したアドレス宛に送信する。
class ReportEmailSettingsScreen extends ConsumerStatefulWidget {
  const ReportEmailSettingsScreen({super.key});

  @override
  ConsumerState<ReportEmailSettingsScreen> createState() =>
      _ReportEmailSettingsScreenState();
}

class _ReportEmailSettingsScreenState
    extends ConsumerState<ReportEmailSettingsScreen> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(sessionProvider).company!.contactEmail,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final email = _controller.text.trim();
    final company = ref.read(sessionProvider).company!;
    setState(() => _isSaving = true);
    try {
      await ref.read(companyServiceProvider).updateContactEmail(
            companyId: company.id,
            contactEmail: email,
          );
      ref.read(sessionProvider.notifier).updateCompany(
            company.copyWith(contactEmail: email),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('送付先メールアドレスを更新しました')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('月次レポート送付先設定')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '毎月1日、前月分の履修状況レポートを設定したメールアドレスへ自動送信します。'
              '空欄の場合は送信されません。',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '送付先メールアドレス',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存する'),
            ),
          ],
        ),
      ),
    );
  }
}
