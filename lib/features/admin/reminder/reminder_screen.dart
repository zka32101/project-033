import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/employee_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';
import '../../../widgets/empty_state_view.dart';

/// 個別リマインド送信(設計書 Must③)。未受講者へ個別に送信できるようにする。
class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  final Set<String> _sentTo = {};

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }
    final company = session.company!;

    return Scaffold(
      appBar: AppBar(title: const Text('個別リマインド送信')),
      body: StreamBuilder<List<Employee>>(
        stream: ref.read(employeeServiceProvider).watchCompanyEmployees(company.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorRetryView(message: '社員一覧の読み込みに失敗しました');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final employees = snapshot.data!;
          if (employees.isEmpty) {
            return const EmptyStateView(
              imagePath: 'assets/images/empty_states/empty_state_no_employees.png',
              message: '社員がまだ登録されていません',
            );
          }
          final colorScheme = Theme.of(context).colorScheme;
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              final sent = _sentTo.contains(employee.id);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        child: Text(
                          employee.displayName.isNotEmpty
                              ? employee.displayName.substring(0, 1)
                              : '?',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          employee.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      sent
                          ? Chip(
                              label: const Text('送信済み'),
                              visualDensity: VisualDensity.compact,
                              backgroundColor: colorScheme.secondaryContainer,
                              labelStyle:
                                  TextStyle(color: colorScheme.onSecondaryContainer),
                            )
                          : OutlinedButton(
                              onPressed: () async {
                                try {
                                  await ref.read(reminderServiceProvider).sendReminder(
                                        companyId: company.id,
                                        employeeId: employee.id,
                                        moduleId: 'all', // 全体向けリマインド
                                      );
                                  setState(() => _sentTo.add(employee.id));
                                } catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('リマインド送信に失敗しました')),
                                    );
                                  }
                                }
                              },
                              child: const Text('送信'),
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
}
