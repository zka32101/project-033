import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/module_model.dart';
import '../../data/models/industry_model.dart';
import '../../data/models/company_model.dart';
import '../../data/models/job_role.dart';
import '../../data/models/subscription_model.dart';
import '../../data/models/enrollment_model.dart';
import '../../core/access_control.dart';
import '../../core/category_priority_resolver.dart';
import '../../core/monthly_focus.dart';
import '../../core/deadline_status.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../../services/content_service.dart';
import '../lesson/lesson_screen.dart';
import '../my_growth/my_growth_screen.dart';
import '../certificates/my_certificates_screen.dart';
import '../admin/team_management/team_management_screen.dart';
import '../paywall/paywall_screen.dart';
import '../training/training_dashboard_screen.dart';
import '../exam/exam_enrollment_screen.dart';
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

  // build() のたびに FutureBuilder へ新しい Future を渡すと、完了後も
  // 再ビルド→再取得→ローディング表示の無限ループになる(SkeletonListの
  // アニメーションと組み合わさるとpumpAndSettleが終わらない)ため、
  // industryId が変わらない限り同じ Future インスタンスを再利用する。
  String? _loadedIndustryId;
  Future<Industry?>? _industryFuture;
  Future<List<Module>>? _modulesFuture;
  Stream<List<Enrollment>>? _enrollmentsStream;

  Future<void> _openModule({
    required Module module,
    required String companyId,
  }) async {
    if (_isNavigating) return;
    _isNavigating = true;
    try {
      // オリジナルモジュール(会社が作成したコンテンツ)はモジュール個別課金の対象外。
      // 作成時点でプレミアムプランの支払いが発生しているため、社員は追加課金なしで閲覧できる。
      final hasAccess = module.isCustom ||
          ref.read(sessionProvider).company?.isTrialActive() == true ||
          AccessControl.moduleAccessGranted(
            isFreeTrial: module.isFreeTrial,
            subscription: await ref
                .read(subscriptionServiceProvider)
                .getActiveSubscription(
                  companyId: companyId,
                  ownerType: SubscriptionOwnerType.company,
                  ownerId: companyId,
                ),
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

  Future<void> _changeJobRole(String? jobRole) async {
    final session = ref.read(sessionProvider);
    final employee = session.employee;
    final company = session.company;
    if (employee == null || company == null) return;
    try {
      await ref.read(employeeServiceProvider).updateJobRole(
            companyId: company.id,
            employeeId: employee.id,
            jobRole: jobRole,
          );
      ref.read(sessionProvider.notifier).signIn(
            employee: jobRole == null
                ? employee.copyWith(clearJobRole: true)
                : employee.copyWith(jobRole: jobRole),
            company: company,
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('職種の変更に失敗しました。時間をおいて再度お試しください')),
      );
    }
  }

  /// グローバルモジュールに、会社が作成したオリジナルモジュール(プレミアムプラン)を
  /// 合流させて優先度順に並べる。
  Future<List<Module>> _loadModules(Industry industry, Company company) async {
    final modules = await ref.read(contentServiceProvider).listModulesForIndustry(
          industry,
          categoryPriorityOverride: company.categoryPriorityOverride,
        );
    final customModules =
        await ref.read(customContentServiceProvider).listCustomModules(company.id);
    final merged = [
      ...modules,
      ...customModules.map((m) => m.toModule()),
    ];
    ContentService.sortModulesByPriority(merged, industry, company.categoryPriorityOverride);
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }
    final company = session.company!;

    if (_loadedIndustryId != company.industryId) {
      _loadedIndustryId = company.industryId;
      _industryFuture = ref.read(contentServiceProvider).getIndustry(company.industryId);
      _modulesFuture = null;
      _enrollmentsStream = ref
          .read(enrollmentServiceProvider)
          .watchEmployeeEnrollments(company.id, session.employee!.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('あなたの必須研修'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: '成長',
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
      body: Column(
        children: [
          if (company.isTrial) _TrialBanner(company: company, isAdmin: session.isAdmin),
          Expanded(
            child: FutureBuilder(
            future: _industryFuture,
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
              _modulesFuture ??= _loadModules(industry, company);
              return FutureBuilder<List<Module>>(
                future: _modulesFuture,
                builder: (context, modulesSnapshot) {
                  if (modulesSnapshot.hasError) {
                    return const ErrorRetryView(message: '研修モジュールの読み込みに失敗しました');
                  }
                  if (!modulesSnapshot.hasData) {
                    return const SkeletonList();
                  }
                  // 職種を選んでいる受講者には、共通モジュールと自分の職種向けのモジュールだけを表示する。
                  final modules = modulesSnapshot.data!
                      .where((m) => m.isAvailableForRole(session.employee!.jobRole))
                      .toList();
                  if (modules.isEmpty) {
                    return const EmptyStateView(
                      imagePath: 'assets/images/empty_states/empty_state_no_modules.png',
                      message: '研修モジュールがまだありません',
                    );
                  }
                  return StreamBuilder<List<Enrollment>>(
                    stream: _enrollmentsStream,
                    builder: (context, enrollmentSnapshot) {
                      final focusModule = MonthlyFocus.pick(
                        priorityOrderedModules: modules,
                        employeeEnrollments: enrollmentSnapshot.data ?? const [],
                      );
                      final colorScheme = Theme.of(context).colorScheme;
                      return ListView(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        children: [
                          _JobRoleSelector(
                            selected: session.employee!.jobRole,
                            onSelected: (id) => _changeJobRole(id),
                          ),
                          // Tier 1 Training セクション（Sep 16-22 自習期間用）
                          Card(
                            color: Colors.indigo.withOpacity(0.1),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TrainingDashboardScreen(),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.school,
                                      color: Colors.indigo[700],
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Tier 1 Training',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.indigo[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Sep 16-22 自習期間',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '4つのモジュール、計16時間',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.indigo[700],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // ライブ認定試験セクション（Oct 10-20 実施）
                          Card(
                            color: Colors.purple.withOpacity(0.1),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ExamEnrollmentScreen(),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      color: Colors.purple[700],
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ライブ認定試験',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.purple[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Oct 10-20 実施',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tier 2/3 試験に挑戦',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.purple[700],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                            // 業種の初期優先度ではなく、管理者がcategory_priority_settings画面で
                            // 上書きした値(company.categoryPriorityOverride)を優先して解決する。
                            // これを使わずindustry.priorityOfだけ見ると、管理者が「必須」に
                            // 変更しても社員側の必須/任意バッジに反映されない不具合になる。
                            final priority = CategoryPriorityResolver.resolve(
                              industry: industry,
                              categoryId: module.categoryId,
                              overrides: company.categoryPriorityOverride,
                            );
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
          ),
        ],
      ),
    );
  }
}


/// お試し(14日・最大5名)中に、残り日数と次の行動(チーム招待)を示すバナー。
class _TrialBanner extends StatelessWidget {
  final Company company;
  final bool isAdmin;

  const _TrialBanner({required this.company, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final active = company.isTrialActive();
    final days = company.trialDaysLeft();
    final colorScheme = Theme.of(context).colorScheme;
    final text = active
        ? 'お試し期間 残り$days日(全モジュール利用可・最大${company.contractedHeadcount}名)'
        : 'お試し期間は終了しました。継続するには有料プランをご契約ください';
    return Material(
      color: active ? colorScheme.primaryContainer : colorScheme.errorContainer,
      child: InkWell(
        onTap: isAdmin
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TeamManagementScreen()),
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(active ? Icons.timer_outlined : Icons.lock_clock, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
              if (isAdmin && active) const Text('メンバーを招待 ›', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}


/// 自分の職種(部門)を選ぶチップ。選ぶと、共通モジュールと自分の職種向けモジュールだけを表示する。
class _JobRoleSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _JobRoleSelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('あなたの職種', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('すべて'),
                    selected: selected == null,
                    onSelected: (_) => onSelected(null),
                  ),
                ),
                for (final role in JobRole.all)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(role.label),
                      selected: selected == role.id,
                      onSelected: (_) => onSelected(role.id),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
