import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/features/help/help_screen.dart';

void main() {
  testWidgets('受講者には受講者向けの使い方だけを表示し、管理者には管理者向けも表示する', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpScreen(isAdmin: false)));
    expect(find.text('研修の受け方'), findsOneWidget);
    expect(find.text('メンバーの招待'), findsNothing);

    await tester.pumpWidget(const MaterialApp(home: HelpScreen(isAdmin: true)));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('メンバーの招待'), 400);
    expect(find.text('メンバーの招待'), findsOneWidget);
  });

  testWidgets('管理者向けに、一括登録・メンバー管理・職種別の必須・操作履歴の説明がある', (tester) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: HelpScreen(isAdmin: true)));
    for (final title in ['メンバー管理', '受講する研修の決め方', '記録と監査']) {
      await tester.scrollUntilVisible(find.text(title), 600);
      expect(find.text(title), findsOneWidget);
    }
    for (final title in ['社員の一括登録', '職種ごとの追加', '操作履歴(監査ログ)']) {
      await tester.scrollUntilVisible(find.text(title), 600);
      expect(find.text(title), findsOneWidget);
    }
    // 受講者には出さない
    await tester.pumpWidget(const MaterialApp(home: HelpScreen(isAdmin: false)));
    expect(find.text('メンバー管理'), findsNothing);
  });

  testWidgets('項目をタップすると本文が開く', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpScreen(isAdmin: false)));
    await tester.tap(find.text('14日間のお試し'));
    await tester.pumpAndSettle();
    expect(find.textContaining('最大5名まで'), findsOneWidget);
  });
}
