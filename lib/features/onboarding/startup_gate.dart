import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import '../invite_entry/invite_entry_screen.dart';

/// 起動時に一度だけonboarding_completedフラグを確認し、初回はOnboardingScreenへ、
/// 2回目以降はInviteEntryScreenへ直行する。
class StartupGate extends StatelessWidget {
  const StartupGate({super.key});

  Future<bool> _hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCompletedOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const InviteEntryScreen() : const OnboardingScreen();
      },
    );
  }
}
