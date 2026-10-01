import 'package:flutter/material.dart';
import '../billing/contract_guide_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/job_role.dart';
import '../../data/models/team_model.dart';
import '../../providers/firebase_providers.dart';
import '../../providers/session_provider.dart';
import '../../widgets/role_badge.dart';
import '../admin/compliance_checklist/compliance_checklist_screen.dart';
import '../admin/team_management/team_management_screen.dart';
import '../help/first_run_guide.dart';

/// アカウント画面。自分の名前・役割(管理者/受講者)と、参加している会社・チームを確認できる。
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  Future<Team?>? _teamFuture;
  String? _loadedTeamKey;

  Future<Team?> _loadTeam(String companyId, String teamId) async {
    if (teamId.isEmpty) return null;
    final doc = await ref.read(firestoreProvider).doc('companies/$companyId/teams/$teamId').get();
    if (!doc.exists) return null;
    return Team.fromMap(doc.id, doc.data()!);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final employee = session.employee;
    final company = session.company;
    if (!session.isSignedIn || employee == null || company == null) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }
    final teamKey = '${company.id}/${employee.teamId}';
    if (_loadedTeamKey != teamKey) {
      _loadedTeamKey = teamKey;
      _teamFuture = _loadTeam(company.id, employee.teamId);
    }
    final isAdmin = session.isAdmin;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント'),
        backgroundColor: isAdmin ? colorScheme.tertiaryContainer : null,
      ),
      body: ListView(
        children: [
          Container(
            color: isAdmin ? colorScheme.tertiaryContainer : colorScheme.secondaryContainer,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      RoleBadge(isAdmin: isAdmin),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const _SectionTitle('参加している会社・チーム'),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('会社名'),
            subtitle: Text(company.name),
          ),
          FutureBuilder<Team?>(
            future: _teamFuture,
            builder: (context, snapshot) {
              final String text;
              if (snapshot.connectionState != ConnectionState.done) {
                text = '読み込み中…';
              } else if (snapshot.hasError) {
                text = '取得できませんでした';
              } else {
                text = snapshot.data?.teamName ?? '(チームに所属していません)';
              }
              return ListTile(
                leading: const Icon(Icons.groups_2_outlined),
                title: const Text('チーム'),
                subtitle: Text(text),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('職種'),
            subtitle: Text(JobRole.labelOf(employee.jobRole) ?? '未設定(ホームで選べます)'),
          ),
          if (company.isTrial)
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('お試し期間'),
              subtitle: Text(
                company.isTrialActive()
                    ? '残り${company.trialDaysLeft()}日(最大${company.contractedHeadcount}名)'
                    : '終了しました',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContractGuideScreen()),
              ),
            ),
          if (isAdmin) ...[
            const _SectionTitle('管理者メニュー'),
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('チーム管理・招待コード'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeamManagementScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('法令対応チェックリスト'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ComplianceChecklistScreen()),
              ),
            ),
          ],
          const _SectionTitle('ヘルプ'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('使い方'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openHelp(context, isAdmin: isAdmin),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
