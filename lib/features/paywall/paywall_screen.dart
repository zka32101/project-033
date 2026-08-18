import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/module_model.dart';
import '../lesson/lesson_screen.dart';
import 'module_selection_screen.dart';

/// ペイウォール(設計書 Step3.5 R④): 業種の高優先カテゴリ1つ無料体験→Aha直後に追加課金訴求。
/// 基本プラン(無料体験モジュールのみ)を超えるモジュールは上位プランでのみ利用できるため、
/// このモジュールを事前選択した状態でModuleSelectionScreen(受講プラン設定)へ誘導する。
class PaywallScreen extends ConsumerWidget {
  final Module module;

  const PaywallScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('モジュールを追加')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(module.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(module.description),
            const SizedBox(height: 32),
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'このモジュールは基本プランの対象外です',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '基本プランでは各カテゴリの無料体験モジュールのみご利用いただけます。'
                      '上位プランに切り替えると、カテゴリごとに必要なモジュールを選んで受講できます'
                      '(利用者数に応じた月額定額制。選ぶモジュール数で料金は変わりません)。',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final saved = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ModuleSelectionScreen(preselectModuleId: module.id),
                    ),
                  );
                  if (saved == true && context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => LessonScreen(module: module)),
                    );
                  }
                },
                child: const Text('上位プランでこのモジュールを含める'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
