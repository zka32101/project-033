import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'features/onboarding/startup_gate.dart';
import 'firebase_options.dart';
import 'widgets/offline_banner.dart';
import 'widgets/force_update_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
