import 'package:flutter/material.dart';
import '../../providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_screen.dart';
import '../learning_path/learning_path_screen.dart';
import '../learning_path/level_diagnostic_screen.dart';
import '../qa_forum/qa_forum_screen.dart';
import '../exam/exam_enrollment_screen.dart';
import '../my_growth/my_growth_screen.dart';
import '../help/first_run_guide.dart';
import '../account/account_screen.dart';

/// メインアプリシェル：ナビゲーションタブ付き
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初回のみ、使い方ガイドを表示する。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FirstRunGuide.showIfNeeded(
        context,
        isAdmin: ref.read(sessionProvider).isAdmin,
      );
    });
  }

  late final List<Widget> _screens = [
    const HomeScreen(),
    const LearningPathScreen(),
    const QAForumScreen(),
    const MyGrowthScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (!session.isSignedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Safy')),
        body: const Center(child: Text('ログインが必要です')),
      );
    }

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: '学習パス',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: 'Q&A',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: '成長',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle),
            label: 'アカウント',
          ),
        ],
      ),
    );
  }
}
