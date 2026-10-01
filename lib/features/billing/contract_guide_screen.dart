import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/billing_config.dart';
import '../../data/models/company_model.dart';
import '../../providers/session_provider.dart';

/// 有料契約の前に、契約方法の違いと注意点を説明する画面。
/// 内容を理解したことを確認してから、契約の申し込みに進める。
class ContractGuideScreen extends ConsumerStatefulWidget {
  const ContractGuideScreen({super.key});

  @override
  ConsumerState<ContractGuideScreen> createState() => _ContractGuideScreenState();
}

class _ContractGuideScreenState extends ConsumerState<ContractGuideScreen> {
  bool _understood = false;

  Future<void> _openInquiry() async {
    final url = BillingConfig.inquiryUrl;
    if (url.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('ご契約の受付は準備中です'),
          content: const Text('請求書払いのお申し込み窓口を準備しています。公開までしばらくお待ちください。'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('閉じる')),
          ],
        ),
      );
      return;
    }
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ページを開けませんでした。時間をおいてお試しください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final company = session.company;
    final isAdmin = session.isAdmin;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('ご契約について')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (company != null) _StatusCard(company: company),
          const SizedBox(height: 16),
          const _Section(
            icon: Icons.help_outline,
            title: 'お試しが終わるとどうなりますか?',
            lines: [
              'お試し期間(14日)が終わると、全モジュールの開放が止まり、無料体験のモジュールのみ利用できます。',
              '登録したメンバー、受講履歴、チェックリストの記録は消えません。契約すると続きから再開できます。',
              '期間の延長や、期限後の自動課金はありません。契約は、管理者が申し込んだときにだけ始まります。',
            ],
          ),
          const _Section(
            icon: Icons.person_outline,
            title: '誰が契約できますか?',
            lines: [
              '契約の申し込みは、会社の管理者が行います。メンバーの方は、管理者にご相談ください。',
              '契約の対象は会社(チーム)単位です。メンバー全員が同じプランを利用します。',
            ],
          ),
          Text('契約方法は2種類あります', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const _MethodCard(
            icon: Icons.receipt_long_outlined,
            title: '請求書払い(Web)',
            badge: '法人におすすめ',
            points: [
              '会社名宛ての請求書(適格請求書)を発行します。',
              '銀行振込やカードでお支払いいただけます(支払い方法は申込時にご案内します)。',
              '経費精算・経理処理に使いやすい方法です。',
              'お申し込みは、アプリ外の申込ページで行います。',
            ],
          ),
          const _MethodCard(
            icon: Icons.shop_2_outlined,
            title: 'ストア課金(Google Play)',
            badge: 'ご案内準備中',
            points: [
              'Google Playのアカウントでお支払いします。',
              '届くのはGoogleの領収書です。会社名宛ての請求書や、適格請求書は発行できません。',
              '解約や返金の手続きは、Google Playのルールに従います。',
              '少人数・個人での利用向けです。',
            ],
          ),
          const SizedBox(height: 8),
          const _Section(
            icon: Icons.info_outline,
            title: 'お申し込み前にご確認ください',
            lines: [
              '2つの方法を同時に契約することはできません。切り替える場合は、いまの契約を終了してからになります。',
              '料金、お支払い時期、解約の条件は、お申し込みの前に申込ページで確認できます。',
              '契約が反映されるまでに、時間がかかる場合があります。反映されないときは、お問い合わせください。',
            ],
          ),
          const SizedBox(height: 8),
          if (!isAdmin)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('契約のお申し込みは、会社の管理者のみ行えます。管理者の方にこの内容をお伝えください。'),
              ),
            )
          else ...[
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _understood,
              onChanged: (v) => setState(() => _understood = v ?? false),
              title: const Text('上記の内容を理解しました'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _understood ? _openInquiry : null,
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('請求書払いで申し込む'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.shop_2_outlined),
              label: Text(BillingConfig.storeBillingAvailable
                  ? 'ストア課金で申し込む'
                  : 'ストア課金(準備中)'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final Company company;
  const _StatusCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final String text;
    if (company.billingSource != BillingSource.none) {
      text = company.billingSource == BillingSource.invoice
          ? '現在のご契約: 請求書払い'
          : '現在のご契約: ストア課金';
    } else if (company.isTrial) {
      text = company.isTrialActive()
          ? 'お試し期間 残り${company.trialDaysLeft()}日'
          : 'お試し期間は終了しました';
    } else {
      text = '現在、有料契約はありません';
    }
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.verified_outlined, color: scheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onPrimaryContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;
  const _Section({required this.icon, required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          ]),
          const SizedBox(height: 8),
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('・'),
                  Expanded(child: Text(l)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final List<String> points;
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.badge,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
              Chip(label: Text(badge, style: const TextStyle(fontSize: 11))),
            ]),
            const SizedBox(height: 8),
            for (final p in points)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('・'),
                    Expanded(child: Text(p, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
