import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/module_model.dart';
import '../../../data/models/enrollment_model.dart';
import '../../../data/models/quiz_attempt_model.dart';
import '../../../core/employee_module_progress.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import '../../../widgets/skeleton_loader.dart';

/// 社員別の受講状況・クイズ点数の詳細(設計書 Must③: チーム別・個人別履修状況確認)。
class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  late Future<List<Module>> _modulesFuture;

  @override
  void initState() {
    super.initState();
    final company = ref.read(sessionProvider).company!;
    _modulesFuture = ref
        .read(contentServiceProvider)
        .getIndustry(company.industryId)
        .then((industry) {
      if (industry == null) return <Module>[];
      return ref.read(contentServiceProvider).listModulesForIndustry(industry);
    });
  }

  String _statusLabel(EnrollmentStatus status) {
    switch (status) {
      case EnrollmentStatus.completed:
        return '完了';
      case EnrollmentStatus.inProgress:
        return '受講中';
      case EnrollmentStatus.notStarted:
        return '未受講';
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final company = session.company!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.employee.displayName}さんの受講状況')),
      body: FutureBuilder<List<Module>>(
        future: _modulesFuture,
        builder: (context, modulesSnapshot) {
          if (modulesSnapshot.hasError) {
            return const ErrorRetryView(message: 'モジュール一覧の読み込みに失敗しました');
          }
          if (!modulesSnapshot.hasData) {
            return const SkeletonList();
          }
          final modules = modulesSnapshot.data!;

          return StreamBuilder<List<Enrollment>>(
            stream: ref
                .read(enrollmentServiceProvider)
                .watchEmployeeEnrollments(company.id, widget.employee.id),
            builder: (context, enrollmentSnapshot) {
              if (enrollmentSnapshot.hasError) {
                return const ErrorRetryView(message: '受講記録の読み込みに失敗しました');
              }
              if (!enrollmentSnapshot.hasData) {
                return const SkeletonList();
              }

              return StreamBuilder<List<QuizAttempt>>(
                stream: ref
                    .read(quizServiceProvider)
                    .watchAttempts(company.id, widget.employee.id),
                builder: (context, attemptSnapshot) {
                  if (attemptSnapshot.hasError) {
                    return const ErrorRetryView(message: 'クイズ結果の読み込みに失敗しました');
                  }
                  if (!attemptSnapshot.hasData) {
                    return const SkeletonList();
                  }

                  final progress = EmployeeModuleProgressBuilder.build(
                    modules: modules,
                    enrollments: enrollmentSnapshot.data!,
                    attempts: attemptSnapshot.data!,
                  );

                  return ListView.builder(
                    itemCount: progress.length,
                    itemBuilder: (context, index) {
                      final item = progress[index];
                      final hasScore = item.latestScore != null;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.module.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _statusLabel(item.status),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasScore)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${item.latestScore}点',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: item.latestPassed == true
                                            ? colorScheme.primary
                                            : colorScheme.error,
                                      ),
                                    ),
                                    Text(
                                      item.attemptCount > 1 ? '受験${item.attemptCount}回' : '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  '未受験',
                                  style: TextStyle(color: colorScheme.outline),
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
      ),
    );
  }
}
