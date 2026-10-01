import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/job_role.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../services/member_admin_service.dart';
import '../../../widgets/error_retry_view.dart';

/// メンバー管理(管理者のみ)。管理者の追加・降格、退職者などの無効化と再有効化を行う。
class MemberManagementScreen extends ConsumerStatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  ConsumerState<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends ConsumerState<MemberManagementScreen> {
  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(action)),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    try {
      await action();
      _toast(done);
    } on FirebaseFunctionsException catch (e) {
      _toast(e.message ?? '処理に失敗しました。時間をおいてお試しください');
    } catch (_) {
      _toast('処理に失敗しました。時間をおいてお試しください');
    }
  }

  Future<void> _onAction(String action, Employee target, List<Employee> members) async {
    final company = ref.read(sessionProvider).company!;
    final actorId = ref.read(sessionProvider).employee!.id;
    final service = ref.read(memberAdminServiceProvider);

    switch (action) {
      case 'promote':
        if (!await _confirm('管理者にしますか?', '${target.displayName}さんが、メンバー管理・契約・レポートなどの管理者機能を使えるようになります。', '管理者にする')) return;
        await _run(() => service.setRole(companyId: company.id, employeeId: target.id, role: EmployeeRole.admin),
            '${target.displayName}さんを管理者にしました');
      case 'demote':
        final why = MemberGuard.whyCannotDemote(members, target);
        if (why != null) return _toast(why);
        if (!await _confirm('メンバーに戻しますか?', '${target.displayName}さんは管理者機能を使えなくなります。', 'メンバーにする')) return;
        await _run(() => service.setRole(companyId: company.id, employeeId: target.id, role: EmployeeRole.member),
            '${target.displayName}さんをメンバーにしました');
      case 'jobrole':
        final picked = await showDialog<String?>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text('${target.displayName}さんの職種'),
            children: [
              for (final r in JobRole.all)
                SimpleDialogOption(
                  onPressed: () => Navigator.of(ctx).pop(r.id),
                  child: Text(r.label + (target.jobRole == r.id ? '  ✓' : '')),
                ),
              SimpleDialogOption(
                onPressed: () => Navigator.of(ctx).pop(''),
                child: const Text('未設定に戻す'),
              ),
            ],
          ),
        );
        if (picked == null) return;
        await _run(
          () => service.setJobRole(
            companyId: company.id,
            employeeId: target.id,
            jobRoleId: picked.isEmpty ? null : picked,
          ),
          picked.isEmpty ? '職種を未設定に戻しました' : '${target.displayName}さんの職種を${JobRole.labelOf(picked)}にしました',
        );
      case 'deactivate':
        final why = MemberGuard.whyCannotDeactivate(members, target, actorId: actorId);
        if (why != null) return _toast(why);
        if (!await _confirm(
          '無効化しますか?',
          '${target.displayName}さんはアプリを使えなくなり、席が1つ空きます。受講の記録は残ります。あとから再有効化もできます。',
          '無効化する',
        )) {
          return;
        }
        await _run(() => service.deactivate(companyId: company.id, employeeId: target.id),
            '${target.displayName}さんを無効化しました');
      case 'reactivate':
        await _run(() => service.reactivate(companyId: company.id, employeeId: target.id),
            '${target.displayName}さんを再有効化しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final company = session.company;
    if (!session.isSignedIn || !session.isAdmin || company == null) {
      return const Scaffold(body: Center(child: Text('管理者のみ利用できます')));
    }
    final actorId = session.employee!.id;

    return Scaffold(
      appBar: AppBar(title: const Text('メンバー管理')),
      body: StreamBuilder<List<Employee>>(
        stream: ref.watch(memberAdminServiceProvider).watchMembers(company.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const ErrorRetryView(message: 'メンバーの読み込みに失敗しました');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final members = snapshot.data!;
          final active = members.where((m) => !m.deactivated).toList()
            ..sort((a, b) {
              if (a.role != b.role) return a.role == EmployeeRole.admin ? -1 : 1;
              return a.displayName.compareTo(b.displayName);
            });
          final inactive = members.where((m) => m.deactivated).toList()
            ..sort((a, b) => a.displayName.compareTo(b.displayName));

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '利用中 ${active.length}名 / 上限 ${company.contractedHeadcount}名',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final m in active)
                _MemberTile(
                  member: m,
                  isSelf: m.id == actorId,
                  onAction: (a) => _onAction(a, m, members),
                ),
              if (inactive.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                  child: Text('無効化されたメンバー(${inactive.length}名)',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                for (final m in inactive)
                  _MemberTile(member: m, isSelf: false, onAction: (a) => _onAction(a, m, members)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Employee member;
  final bool isSelf;
  final ValueChanged<String> onAction;

  const _MemberTile({required this.member, required this.isSelf, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAdmin = member.role == EmployeeRole.admin;
    final sub = [
      JobRole.labelOf(member.jobRole) ?? '職種未設定',
      '参加 ${member.createdAt.year}/${member.createdAt.month}/${member.createdAt.day}',
    ].join('  ・  ');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: member.deactivated ? scheme.surfaceContainerHighest : scheme.primaryContainer,
        child: Text(member.displayName.isEmpty ? '?' : member.displayName.characters.first),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              member.displayName + (isSelf ? '(あなた)' : ''),
              overflow: TextOverflow.ellipsis,
              style: member.deactivated ? TextStyle(color: scheme.outline) : null,
            ),
          ),
          if (isAdmin && !member.deactivated) ...[
            const SizedBox(width: 8),
            Chip(
              label: const Text('管理者', style: TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: PopupMenuButton<String>(
        tooltip: '操作',
        onSelected: onAction,
        itemBuilder: (_) => [
          if (member.deactivated)
            const PopupMenuItem(value: 'reactivate', child: Text('再有効化する'))
          else ...[
            if (isAdmin)
              const PopupMenuItem(value: 'demote', child: Text('メンバーにする'))
            else
              const PopupMenuItem(value: 'promote', child: Text('管理者にする')),
            const PopupMenuItem(value: 'jobrole', child: Text('職種を設定する')),
            const PopupMenuItem(value: 'deactivate', child: Text('無効化する(退職など)')),
          ],
        ],
      ),
    );
  }
}
