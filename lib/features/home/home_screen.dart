import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/module_model.dart';
import '../../data/models/subscription_model.dart';
import '../../data/models/enrollment_model.dart';
import '../../core/access_control.dart';
import '../../core/monthly_focus.dart';
import '../../core/deadline_status.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../lesson/lesson_screen.dart';
import '../my_growth/my_growth_screen.dart';
import '../certificates/my_certificates_screen.dart';
import '../admin/team_management/team_management_screen.dart';
import '../paywall/paywall_screen.dart';
import '../../widgets/error_retry_view.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state_view.dart';

/// ホーム画面: 業種の優先モジュールを表示(Aha Moment動線の中核)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // モジュールカードのタップ→非同期の契約確認→画面遷移の間に連打されると
  // 同じモジュールの画面が二重に積まれてしまうため、遷移中は再タップを無視する。
  bool _isNavigating = false;

  Future<void> _openModule({
    required Module module,
    required String companyId,
  }) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      final subscription = await ref
          .read(subscriptionServiceProvider)
          .getActiveSubscription(
            companyId: companyId,
            ownerType: SubscriptionOwnerType.company,
            ownerId: companyId,
          );
      final hasAccess = AccessControl.moduleAccessGranted(
        isFreeTrial: module.isFreeTrial,
        subscription: subscription,
        moduleId: module.id,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => hasAccess
              ? LessonScreen(module: module)
              : PaywallScreen(module: module),
        ),
      );
    } finally {
      _isNavigating = false;
    }
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
        title: const Text('あなたの必須研修'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'マイ成長',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyGrowthScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.verified_outlined),
            tooltip: '修了証',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyCertificatesScreen()),
            ),
          ),
          if (session.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: '管理者メニュー',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TeamManagementScreen()),
              ),
            ),
        ],
      ),
      body: FutureBuilder(
        future: ref.read(contentServiceProvider).getIndustry(company.industryId),
        builder: (context, industrySnapshot) {
          if (industrySnapshot.hasError) {
            return const ErrorRetryView(message: '業種情報の読み込みに失敗しました');
          }
          if (!industrySnapshot.hasData) {
            return const SkeletonList();
          }
          final industry = industrySnapshot.data;
          if (industry == null) {
            return const Center(child: Text('業種情報が見つかりませんでした'));
          }
          return FutureBuilder<List<Module>>(
            future: ref.read(contentServiceProvider).listModulesForIndustry(
                  industry,
                  categoryPriorityOverride: company.categoryPriorityOverride,
                ),
            builder: (context, modulesSnapshot) {
              if (modulesSnapshot.hasError) {
                return const ErrorRetryView(message: '研修モジュールの読み込みに失敗しました');
              }
              if (!modulesSnapshot.hasData) {
                return const SkeletonList();
              }
              final modules = modulesSnapshot.data!;
              if (modules.isEmpty) {
                return const EmptyStateView(
                  imagePath: 'assets/images/empty_states/empty_state_no_modules.png',
                  message: '研修モジュールがまだありません',
                );
              }
              return StreamBuilder<List<Enrollment>>(
                stream: ref
                    .read(enrollmentServiceProvider)
                    .watchEmployeeEnrollments(company.id, session.employee!.id),
                builder: (context, enrollmentSnapshot) {
                  final focusModule = MonthlyFocus.pick(
                    priorityOrderedModules: modules,
                    employeeEnrollments: enrollmentSnapshot.data ?? const [],
                  );
                  final colorScheme = Theme.of(context).colorScheme;
                  return ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    children: [
                      if (focusModule != null)
                        Card(
                          color: colorScheme.primaryContainer,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openModule(
                              module: focusModule,
                              companyId: company.id,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.flag, color: colorScheme.onPrimaryContainer),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '今月の必須モジュール',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onPrimaryContainer
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          focusModule.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: colorScheme.onPrimaryContainer),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ...modules.map((module) {
                        final priority = industry.priorityOf(module.categoryId);
                        final isRequired = priority == 2;
                        final enrollments = enrollmentSnapshot.data ?? const [];
                        final isCompleted = enrollments.any((e) =>
                            e.moduleId == module.id &&
                            e.status == EnrollmentStatus.completed);
                        final deadlineStatus = DeadlineStatusEvaluator.evaluate(
                          dueDate: company.deadlineFor(module.id),
                          isCompleted: isCompleted,
                          now: DateTime.now(),
                        );
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openModule(module: module, companyId: company.id),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isRequired
                                          ? colorScheme.primary
                                          : colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isRequired ? '必須' : '任意',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isRequired
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          module.title,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          module.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (module.isFreeTrial ||
                                            deadlineStatus != DeadlineStatus.none) ...[
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 6,
                                            children: [
                                              if (module.isFreeTrial)
                                                Chip(
                                                  label: const Text('無料体験'),
                                                  visualDensity: VisualDensity.compact,
                                                  backgroundColor:
                                                      colorScheme.tertiaryContainer,
                                                  labelStyle: TextStyle(
                                                    color: colorScheme.onTertiaryContainer,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              if (deadlineStatus == DeadlineStatus.upcoming)
                                                Chip(
                                                  avatar: const Icon(Icons.schedule, size: 14),
                                                  label: const Text('期限間近'),
                                                  visualDensity: VisualDensity.compact,
                                                  backgroundColor:
                                                      colorScheme.tertiaryContainer,
                                                  labelStyle: TextStyle(
                                                    color: colorScheme.onTertiaryContainer,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              if (deadlineStatus == DeadlineStatus.overdue)
                                                Chip(
                                                  avatar: const Icon(Icons.error_outline,
                                                      size: 14),
                                                  label: const Text('期限超過'),
                                                  visualDensity: VisualDensity.compact,
                                                  backgroundColor: colorScheme.errorContainer,
                                                  labelStyle: TextStyle(
                                                    color: colorScheme.onErrorContainer,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: colorScheme.outline),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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
