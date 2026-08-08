import 'package:flutter/material.dart';

/// FutureBuilder/StreamBuilderのエラー状態を統一的に表示するウィジェット。
/// snapshot.hasErrorをチェックせず読み込み中スピナーが回り続ける「サイレントハング」を防ぐ。
class ErrorRetryView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorRetryView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('再読み込み')),
            ],
          ],
        ),
      ),
    );
  }
}
