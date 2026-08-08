import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../invite_entry/invite_entry_screen.dart';

class _OnboardingSlide {
  final String imagePath;
  final String title;
  final String description;

  const _OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

const _slides = [
  _OnboardingSlide(
    imagePath: 'assets/images/onboarding/onboarding_1_industry.png',
    title: '業種に合わせて自動で優先度を提案',
    description: '製造業・建設業・医療福祉など、業種ごとに本当に必要な研修だけを最初に表示します。',
  ),
  _OnboardingSlide(
    imagePath: 'assets/images/onboarding/onboarding_2_microlearning.png',
    title: 'スキマ時間で3〜5分から',
    description: '通勤・休憩時間に1テーマずつ。負担の少ないマイクロラーニングで学べます。',
  ),
  _OnboardingSlide(
    imagePath: 'assets/images/onboarding/onboarding_3_certificate.png',
    title: '修了証で法令対応の証跡に',
    description: '受講記録・合格ラインは監査証跡として記録され、企業のコンプライアンス対応に活用できます。',
  ),
];

/// 初回起動時のみ表示するオンボーディング(設計書 Step4)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const InviteEntryScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('スキップ'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(slide.imagePath, height: 220),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => Container(
                  margin: const EdgeInsets.all(4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: isLast
                    ? _finish
                    : () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                child: Text(isLast ? '始める' : '次へ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
