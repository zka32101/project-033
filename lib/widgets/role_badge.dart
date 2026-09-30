import 'package:flutter/material.dart';

/// 管理者アカウントと受講者(メンバー)アカウントを、見た目で区別するための小さなバッジ。
class RoleBadge extends StatelessWidget {
  final bool isAdmin;

  const RoleBadge({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isAdmin ? colorScheme.tertiary : colorScheme.secondaryContainer;
    final foreground = isAdmin ? colorScheme.onTertiary : colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? '管理者' : '受講者',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: foreground),
          ),
        ],
      ),
    );
  }
}
