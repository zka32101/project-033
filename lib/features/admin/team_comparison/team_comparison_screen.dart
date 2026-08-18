import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/team_model.dart';
import '../../../core/dashboard_analytics.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import '../../../widgets/skeleton_loader.dart';

/// チーム単位受講率比較(設計書 Must③、部門・拠点ごとの温度差の可視化)
class TeamComparisonScreen extends ConsumerStatefulWidget {
  const TeamComparisonScreen({super.key});

  @override
  ConsumerState<TeamComparisonScreen> createState() => _TeamComparisonScreenState();
}

class _TeamComparisonScreenState extends ConsumerState<TeamComparisonScreen> {
  late final Future<int> _totalModulesFuture;
  late final Future<List<Team>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    final company = ref.read(sessionProvider).company!;
    _totalModulesFuture = ref
        .read(contentServiceProvider)
        .getIndustry(company.industryId)
        .then((industry) async {
      if (industry == null) return 0;
      final modules =
          await ref.read(contentServiceProvider).listModulesForIndustry(industry);
      final customModules =
          await ref.read(customContentServiceProvider).listCustomModules(company.id);
      return modules.length + customModules.length;
    });
    _teamsFuture = ref
        .read(firestoreProvider)
        .collection('companies/${company.id}/teams')
        .get()
        .then((snap) => snap.docs.map((d) => Team.fromMap(d.id, d.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }
    final company = session.company!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('チーム別受講率比較')),
      body: FutureBuilder<int>(
        future: _totalModulesFuture,
        builder: (context, totalModulesSnapshot) {
          if (totalModulesSnapshot.hasError) {
            return const ErrorRetryView(message: 'モジュール数の集計に失敗しました');
          }
          if (!totalModulesSnapshot.hasData) {
            return const SkeletonList();
          }
          final totalModules = totalModulesSnapshot.data!;

          return FutureBuilder<List<Team>>(
            future: _teamsFuture,
            builder: (context, teamsSnapshot) {
              if (teamsSnapshot.hasError) {
                return const ErrorRetryView(message: 'チーム一覧の読み込みに失敗しました');
              }
              if (!teamsSnapshot.hasData) {
                return const SkeletonList();
              }
              final teamNameById = {
                for (final team in teamsSnapshot.data!) team.id: team.teamName,
              };

              return StreamBuilder<List<Employee>>(
                stream: ref.read(employeeServiceProvider).watchCompanyEmployees(company.id),
                builder: (context, employeeSnapshot) {
                  if (employeeSnapshot.hasError) {
                    return const ErrorRetryView(message: '社員一覧の読み込みに失敗しました');
                  }
                  if (!employeeSnapshot.hasData) {
                    return const SkeletonList();
                  }
                  final employees = employeeSnapshot.data!;

                  return StreamBuilder<List<Enrollment>>(
                    stream: ref
                        .read(enrollmentServiceProvider)
                        .watchCompanyEnrollments(company.id),
                    builder: (context, enrollmentSnapshot) {
                      if (enrollmentSnapshot.hasError) {
                        return const ErrorRetryView(message: '受講記録の読み込みに失敗しました');
                      }
                      if (!enrollmentSnapshot.hasData) {
                        return const SkeletonList();
                      }

                      final teamStats = DashboardAnalytics.computeTeamCompletionStats(
                        employees: employees,
                        enrollments: enrollmentSnapshot.data!,
                        totalModuleCount: totalModules,
                      );

                      if (teamStats.isEmpty) {
                        return const Center(child: Text('社員が登録されていません'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: teamStats.length,
                        itemBuilder: (context, index) {
                          final stat = teamStats[index];
                          final teamName = stat.teamId.isEmpty
                              ? '未所属'
                              : (teamNameById[stat.teamId] ?? stat.teamId);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          teamName,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        '${stat.completionRatePercent}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: stat.completionRatePercent / 100,
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '所属社員 ${stat.employeeCount}名',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
