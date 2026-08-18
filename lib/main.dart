import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'features/onboarding/startup_gate.dart';
import 'widgets/offline_banner.dart';
import 'widgets/force_update_gate.dart';

// Firebase.initializeApp()は firebase_options.dart 生成後([flutter-firebase-setup]で
// Firebase Console設定完了後)に追加する。未設定の状態で呼ぶと起動時に例外になるため、
// Firebase Console作業が完了するまではここに追加しない。

void main() {
  runApp(const ProviderScope(child: SafyApp()));
}

class SafyApp extends StatelessWidget {
  const SafyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '安心企業研修Safy',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      builder: (context, child) => OfflineBanner(
        child: ForceUpdateGate(child: child ?? const SizedBox()),
      ),
      home: const StartupGate(),
    );
  }
}
