import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/invite_code_model.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../dashboard/admin_dashboard_screen.dart';
import '../../../widgets/error_retry_view.dart';
import '../../../widgets/empty_state_view.dart';

/// チーム管理: チーム作成・招待コード発行(設計書 Must③)
class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  ConsumerState<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState extends ConsumerState<TeamManagementScreen> {
  final Map<String, InviteCode> _issuedCodes = {};
  bool _isIssuing = false;
  late Future<List<Team>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    // FutureBuilderのfutureをbuild()内で毎回生成すると、招待コード発行時の
    // setState(_isIssuing切り替え等)のたびにチーム一覧が再取得されちらつくため、
    // 明示的にリロードする箇所(_reloadTeams)以外ではFutureを使い回す。
    _teamsFuture = _fetchTeams(ref.read(sessionProvider).company!.id);
  }

  void _reloadTeams(String companyId) {
    setState(() => _teamsFuture = _fetchTeams(companyId));
  }

  Future<void> _issueCodeFor(String companyId, String teamId) async {
    setState(() => _isIssuing = true);
    try {
      final code = await ref
          .read(inviteServiceProvider)
          .issueInviteCode(companyId: companyId, teamId: teamId);
      try {
        await ref
            .read(analyticsServiceProvider)
            .logEmployeeInvited(companyId: companyId);
      } catch (_) {
        // 計測ログ送信の失敗はコード発行自体の成否に影響させない。
      }
      setState(() => _issuedCodes[teamId] = code);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('招待コードの発行に失敗しました。時間をおいて再度お試しください')),
        );
      }
    } finally {
      if (mounted) setState(() => _isIssuing = false);
    }
  }

  Future<void> _createTeam(String companyId, String teamName) async {
    try {
      await ref
          .read(inviteServiceProvider)
          .createTeam(companyId: companyId, teamName: teamName);
      _reloadTeams(companyId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('チームの作成に失敗しました。時間をおいて再度お試しください')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }
    final companyId = session.company!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('チーム管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: '履修状況ダッシュボード',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = TextEditingController();
          final teamName = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('新しいチーム名'),
              content: TextField(controller: controller, autofocus: true),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, controller.text.trim()),
                  child: const Text('作成'),
                ),
              ],
            ),
          );
          if (teamName != null && teamName.isNotEmpty) {
            await _createTeam(companyId, teamName);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Team>>(
        future: _teamsFuture,
        builder: (context, teamsSnapshot) {
          if (teamsSnapshot.hasError) {
            return ErrorRetryView(
              message: 'チーム一覧の読み込みに失敗しました',
              onRetry: () => _reloadTeams(companyId),
            );
          }
          if (!teamsSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final teams = teamsSnapshot.data!;
          if (teams.isEmpty) {
            return const EmptyStateView(
              imagePath: 'assets/images/empty_states/empty_state_no_employees.png',
              message: 'チームがまだありません。右下の+から作成してください',
            );
          }
          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final issuedCode = _issuedCodes[team.id];
              final colorScheme = Theme.of(context).colorScheme;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.groups_2_outlined, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(team.teamName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (issuedCode != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.vpn_key_outlined,
                                  size: 18, color: colorScheme.onPrimaryContainer),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText(
                                  issuedCode.code,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _isIssuing
                                ? null
                                : () => _issueCodeFor(companyId, team.id),
                            child: const Text('招待コードを発行する'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Team>> _fetchTeams(String companyId) async {
    // シンプルなFutureBuilder取得(チーム数が少ないため一覧全件取得で十分)
    final snap = await ref
        .read(firestoreProvider)
        .collection('companies/$companyId/teams')
        .get();
    return snap.docs.map((d) => Team.fromMap(d.id, d.data())).toList();
  }
}
