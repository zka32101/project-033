import 'package:flutter/material.dart';

/// 空状態表示の共通ウィジェット(社員未登録・モジュール未受講など)。
/// BtoBトーンを保ちつつ、素っ気ないテキストのみの表示より親しみやすさを補う。
class EmptyStateView extends StatelessWidget {
  final String imagePath;
  final String message;

  const EmptyStateView({super.key, required this.imagePath, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 160, height: 160),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
