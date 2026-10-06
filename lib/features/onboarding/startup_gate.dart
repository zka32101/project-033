import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../dashboard/app_shell.dart';
import 'onboarding_screen.dart';
import '../invite_entry/invite_entry_screen.dart';

/// 起動時に一度だけ次を判定する。
/// 1. 保存済みセッションがあり、Firebase Authのユーザーとサーバー上のデータが有効なら AppShell へ復元
/// 2. onboarding_completedが未設定なら OnboardingScreen
/// 3. それ以外は InviteEntryScreen
class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key});

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  late final Future<Widget> _destination = _resolve();

  Future<Widget> _resolve() async {
    final restored = await _tryRestoreSession();
    if (restored) return const AppShell();
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_completed') ?? false;
    return done ? const InviteEntryScreen() : const OnboardingScreen();
  }

  Future<bool> _tryRestoreSession() async {
    try {
      final ids = await SessionNotifier.savedIds();
      if (ids == null) return false;
      // 匿名認証のuidが失われていると、Firestoreルール上アクセスできない。
      if (FirebaseAuth.instance.currentUser == null) return false;
      final employee = await ref
          .read(employeeServiceProvider)
          .getEmployee(ids.companyId, ids.employeeId);
      final company = await ref.read(companyServiceProvider).getCompany(ids.companyId);
      if (employee == null || company == null) {
        ref.read(sessionProvider.notifier).signOut();
        return false;
      }
      ref.read(sessionProvider.notifier).signIn(employee: employee, company: company);
      return true;
    } catch (_) {
      // ネットワーク不通などは通常のサインイン導線にフォールバックする。
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _destination,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // 起動中の読み込み画面。下部に組織（Your Wish）のロゴを出す。
          return Scaffold(
            body: Column(
              children: [
                const Expanded(child: Center(child: CircularProgressIndicator())),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Semantics(
                      label: 'Your Wish',
                      child: Image.asset(
                        'assets/images/branding/yourwish_logo.png',
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
