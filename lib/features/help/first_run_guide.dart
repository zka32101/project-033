import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'help_screen.dart';

const _guideDoneKey = 'first_run_guide_done';

class _GuideStep {
  final IconData icon;
  final String title;
  final String body;

  const _GuideStep(this.icon, this.title, this.body);
}

const List<_GuideStep> _learnerSteps = [
  _GuideStep(
    Icons.waving_hand_outlined,
    'ようこそ、Safyへ',
    '仕事で必要なセキュリティ・コンプライアンス・安全衛生の研修を、スマートフォンで短時間ずつ受けられます。',
  ),
  _GuideStep(
    Icons.badge_outlined,
    'まず職種を選びましょう',
    'ホーム上部の「あなたの職種」を選ぶと、自分の仕事に合った研修が表示されます。あとから何度でも変更できます。',
  ),
  _GuideStep(
    Icons.menu_book_outlined,
    '研修を受けて修了しよう',
    'カードをタップしてレッスンを読み、最後のクイズに合格すると修了です。合格ラインに届かなくても、何度でも再挑戦できます。',
  ),
  _GuideStep(
    Icons.workspace_premium_outlined,
    '成長と修了証を確認',
    '「成長」タブで学習の進み具合を、右上のアイコンで修了証を確認できます。困ったときは、右上の「?」から使い方を見られます。',
  ),
];

const _adminStep = _GuideStep(
  Icons.group_add_outlined,
  'メンバーを招待しましょう',
  '右上の管理者メニューから招待コードを発行し、メンバーに共有します。お試しチームは、14日間・最大5名まで無料で試せます。',
);

/// 初回のみ表示するステップ式の使い方ガイド。
/// 表示済みかどうかは端末に保存する。保存領域が使えない環境では表示しない(起動を妨げない)。
class FirstRunGuide {
  static Future<void> showIfNeeded(BuildContext context, {required bool isAdmin}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_guideDoneKey) ?? false) return;
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _GuideDialog(isAdmin: isAdmin),
      );
      await prefs.setBool(_guideDoneKey, true);
    } catch (_) {
      // ガイドの表示失敗はアプリの利用に影響させない。
    }
  }
}

class _GuideDialog extends StatefulWidget {
  final bool isAdmin;

  const _GuideDialog({required this.isAdmin});

  @override
  State<_GuideDialog> createState() => _GuideDialogState();
}

class _GuideDialogState extends State<_GuideDialog> {
  final _controller = PageController();
  int _page = 0;

  List<_GuideStep> get _steps => [
        ..._learnerSteps,
        if (widget.isAdmin) _adminStep,
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final isLast = _page == steps.length - 1;
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      content: SizedBox(
        width: 320,
        height: 260,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(steps[i].icon, size: 56, color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      steps[i].title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      steps[i].body,
                      style: const TextStyle(height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < steps.length; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('スキップ'),
        ),
        if (isLast)
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('はじめる'),
          )
        else
          FilledButton(
            onPressed: () => _controller.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            ),
            child: const Text('次へ'),
          ),
      ],
    );
  }

  bool get isLast => _page == _steps.length - 1;
}

/// ヘルプ画面を開く。
void openHelp(BuildContext context, {required bool isAdmin}) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => HelpScreen(isAdmin: isAdmin)),
  );
}
