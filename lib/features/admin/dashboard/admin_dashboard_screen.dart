import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../core/dashboard_analytics.dart';
import '../../../core/churn_risk.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../reminder/reminder_screen.dart';
import '../report_export/report_export_screen.dart';
import '../pass_threshold/pass_threshold_settings_screen.dart';
import '../deadline_settings/deadline_settings_screen.dart';
import '../report_email_settings/report_email_settings_screen.dart';
import '../category_priority_settings/category_priority_settings_screen.dart';
import '../original_content/original_content_screen.dart';
import '../../paywall/module_selection_screen.dart';
import '../employee_detail/employee_detail_screen.dart';
import '../team_comparison/team_comparison_screen.dart';
import '../../../widgets/error_retry_view.dart';
import '../../../widgets/skeleton_loader.dart';

/// 履修状況ダッシュボード(チーム別・個人別)。設計書 Must③。
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  // 業種のモジュール総数はほぼ不変のため、enrollments/employeesのライブ更新のたびに
  // 再取得してダッシュボード全体がスケルトンに戻る(ちらつく)ことがないよう一度だけ取得する。
  late final Future<int> _totalModulesFuture;

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
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }
    final company = session.company!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('履修状況ダッシュボード'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: '個別リマインド送信',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReminderScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'レポート出力',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportExportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'チーム別受講率比較',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TeamComparisonScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '受講設定',
            onSelected: (value) {
              if (value == 'pass_threshold') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PassThresholdSettingsScreen()),
                );
              } else if (value == 'deadline') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DeadlineSettingsScreen()),
                );
              } else if (value == 'report_email') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportEmailSettingsScreen()),
                );
              } else if (value == 'category_priority') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoryPrioritySettingsScreen()),
                );
              } else if (value == 'original_content') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OriginalContentScreen()),
                );
              } else if (value == 'module_plan') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ModuleSelectionScreen()),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'module_plan', child: Text('受講プラン設定(基本/上位)')),
              PopupMenuItem(value: 'pass_threshold', child: Text('合格ライン設定')),
              PopupMenuItem(value: 'deadline', child: Text('受講期限設定')),
              PopupMenuItem(value: 'report_email', child: Text('月次レポート送付先設定')),
              PopupMenuItem(value: 'category_priority', child: Text('業種プロファイル調整')),
              PopupMenuItem(
                  value: 'original_content', child: Text('オリジナルコンテンツ管理(プレミアム)')),
            ],
          ),
        ],
      ),
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
                stream:
                    ref.read(enrollmentServiceProvider).watchCompanyEnrollments(company.id),
                builder: (context, enrollmentSnapshot) {
                  if (enrollmentSnapshot.hasError) {
                    return const ErrorRetryView(message: '受講記録の読み込みに失敗しました');
                  }
                  if (!enrollmentSnapshot.hasData) {
                    return const SkeletonList();
                  }
                  final enrollments = enrollmentSnapshot.data!;

                  final stats = DashboardAnalytics.computeEmployeeCompletionStats(
                    employees: employees,
                    enrollments: enrollments,
                    totalModuleCount: totalModules,
                  );
                  final overall = DashboardAnalytics.overallCompletionRatePercent(stats);
                  final churnRisk = ChurnRisk.evaluate(
                    overallCompletionRatePercent: overall,
                    daysSinceCompanyCreated:
                        DateTime.now().difference(company.createdAt).inDays,
                  );

                  final colorScheme = Theme.of(context).colorScheme;
                  return Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.groups, color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '全社受講率',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '$overall%',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (churnRisk != ChurnRiskLevel.low)
                        Card(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                          color: churnRisk == ChurnRiskLevel.high
                              ? colorScheme.errorContainer
                              : colorScheme.tertiaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber,
                                  color: churnRisk == ChurnRiskLevel.high
                                      ? colorScheme.onErrorContainer
                                      : colorScheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '受講率が低下しています。個別リマインド送信をご検討ください',
                                    style: TextStyle(
                                      color: churnRisk == ChurnRiskLevel.high
                                          ? colorScheme.onErrorContainer
                                          : colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: ListView.builder(
                          itemCount: stats.length,
                          itemBuilder: (context, index) {
                            final stat = stats[index];
                            final employee = employees.firstWhere(
                              (e) => e.id == stat.employeeId,
                              orElse: () => employees[index],
                            );
                            return Card(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EmployeeDetailScreen(employee: employee),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              stat.displayName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: stat.completionRatePercent / 100,
                                                minHeight: 6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${stat.completionRatePercent}%',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right, color: colorScheme.outline),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
