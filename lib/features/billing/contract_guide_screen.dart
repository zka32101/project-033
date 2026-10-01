import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../core/billing_config.dart';
import '../../providers/service_providers.dart';
import '../../data/models/company_model.dart';
import '../../providers/session_provider.dart';

/// 有料契約の前に、契約方法の違いと注意点を説明する画面。
/// 内容を理解したことを確認してから、契約の申し込みに進める。
class ContractGuideScreen extends ConsumerStatefulWidget {
  const ContractGuideScreen({super.key});

  @override
  ConsumerState<ContractGuideScreen> createState() =>
      _ContractGuideScreenState();
}

class _ContractGuideScreenState extends ConsumerState<ContractGuideScreen>
    with WidgetsBindingObserver {
  bool _understood = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 決済ページから戻ったときに、契約の反映を確認するため会社情報を取り直す。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshCompany();
  }

  Future<void> _refreshCompany() async {
    final id = ref.read(sessionProvider).company?.id;
    if (id == null) return;
    try {
      final latest = await ref.read(companyServiceProvider).getCompany(id);
      if (latest != null && mounted) {
        ref.read(sessionProvider.notifier).updateCompany(latest);
      }
    } catch (_) {
      // 取得に失敗しても画面はそのまま使える。次の復帰時に再取得する。
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openUrl(Uri url) async {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok) _toast('ページを開けませんでした。時間をおいてお試しください');
  }

  Future<int?> _askSeats() {
    final controller = TextEditingController(text: '5');
    return showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final seats = int.tryParse(controller.text.trim());
          final valid = seats != null && seats >= 1 && seats <= 1000;
          return AlertDialog(
            title: const Text('ご利用人数'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('契約する人数を入力してください。現在のメンバー数より少ない人数は選べません。'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: '人数(1〜1000)',
                    suffixText: '名',
                  ),
                  onChanged: (_) => setLocal(() {}),
                ),
                const SizedBox(height: 8),
                const Text(
                  '決済ページで、料金と請求内容を確認してから確定できます。',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: valid ? () => Navigator.of(ctx).pop(seats) : null,
                child: const Text('決済ページへ'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _run(Future<Uri> Function() fetch) async {
    setState(() => _busy = true);
    try {
      await _openUrl(await fetch());
    } on FirebaseFunctionsException catch (e) {
      _toast(e.message ?? '処理に失敗しました。時間をおいてお試しください');
    } catch (_) {
      _toast('処理に失敗しました。時間をおいてお試しください');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startCheckout(String companyId) async {
    final seats = await _askSeats();
    if (seats == null) return;
    await _run(
      () => ref
          .read(billingServiceProvider)
          .createCheckoutUrl(companyId: companyId, seats: seats),
    );
  }

  Future<void> _openPortal(String companyId) => _run(
    () =>
        ref.read(billingServiceProvider).createPortalUrl(companyId: companyId),
  );

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
            if (company?.billingSource == BillingSource.invoice)
              FilledButton.icon(
                onPressed: _busy ? null : () => _openPortal(company!.id),
                icon: const Icon(Icons.manage_accounts_outlined),
                label: const Text('請求書・支払い方法・解約の管理'),
              )
            else
              FilledButton.icon(
                onPressed: (_understood && !_busy && company != null)
                    ? () => _startCheckout(company.id)
                    : null,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('請求書払いで申し込む'),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.shop_2_outlined),
              label: Text(
                BillingConfig.storeBillingAvailable
                    ? 'ストア課金で申し込む'
                    : 'ストア課金(準備中)',
              ),
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
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimaryContainer,
                ),
              ),
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
  const _Section({
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
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
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Chip(label: Text(badge, style: const TextStyle(fontSize: 11))),
              ],
            ),
            const SizedBox(height: 8),
            for (final p in points)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('・'),
                    Expanded(
                      child: Text(p, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
