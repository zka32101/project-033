import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/team_model.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../module_assignment/extra_modules_screen.dart';

/// チーム別の必須研修の設定。全社共通の必須に加えて、このチームだけ必須にする研修を選ぶ
/// (例: 営業チームだけ景品表示法、経理チームだけインボイス制度)。
class TeamModuleAssignmentScreen extends ConsumerWidget {
  final Team team;

  const TeamModuleAssignmentScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ExtraModulesScreen(
      title: '${team.teamName}の必須研修',
      intro: '全社共通の必須に加えて、このチームだけ必須にする研修を選びます。'
          '全社共通の必須(グレー)は、「受講コンテンツの設定」で変更できます。',
      countLabel: (n) => 'このチームの追加: $n件',
      initialIds: team.assignedModuleIds,
      savedMessage: (n) => '${team.teamName}の追加の必須研修($n件)を保存しました',
      onSave: (ids) => ref.read(companyServiceProvider).updateTeamAssignedModules(
            companyId: ref.read(sessionProvider).company!.id,
            teamId: team.id,
            moduleIds: ids,
          ),
    );
  }
}
