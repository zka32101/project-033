import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/job_role.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import 'extra_modules_screen.dart';

/// 職種別の必須研修(管理者のみ)。職種を選び、全社共通の必須に加えて、その職種だけ必須にする研修を設定する
/// (例: 経理は振込詐欺対策、営業は景品表示法、管理職はハラスメント対応)。
class RoleAssignmentScreen extends ConsumerWidget {
  const RoleAssignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final company = session.company;
    if (!session.isSignedIn || !session.isAdmin || company == null) {
      return const Scaffold(body: Center(child: Text('管理者のみ利用できます')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('職種別の必須研修')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '職種を選んで、その職種だけ必須にする研修を設定します。メンバーの職種は、本人がホームで選ぶか、'
              '管理者がメンバー管理から設定できます。',
            ),
          ),
          for (final role in JobRole.all)
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(role.label),
              subtitle: Text(
                (company.roleAssignments[role.id] ?? const []).isEmpty
                    ? '追加の必須研修なし'
                    : '追加の必須研修 ${company.roleAssignments[role.id]!.length}件',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExtraModulesScreen(
                    title: '${role.label}の必須研修',
                    intro: '全社共通の必須に加えて、${role.label}の人だけ必須にする研修を選びます。'
                        '全社共通の必須(グレー)は、「受講コンテンツの設定」で変更できます。',
                    countLabel: (n) => '${role.label}の追加: $n件',
                    initialIds: company.roleAssignments[role.id] ?? const [],
                    savedMessage: (n) => '${role.label}の追加の必須研修($n件)を保存しました',
                    onSave: (ids) async {
                      await ref.read(companyServiceProvider).updateRoleAssignedModules(
                            companyId: company.id,
                            jobRoleId: role.id,
                            moduleIds: ids,
                          );
                      // 一覧とホームの表示に反映する。
                      final current = ref.read(sessionProvider).company!;
                      ref.read(sessionProvider.notifier).updateCompany(
                            current.copyWith(roleAssignments: {...current.roleAssignments, role.id: ids}),
                          );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
