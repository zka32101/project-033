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

  testWidgets('項目をタップすると本文が開く', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HelpScreen(isAdmin: false)));
    await tester.tap(find.text('14日間のお試し'));
    await tester.pumpAndSettle();
    expect(find.textContaining('最大5名まで'), findsOneWidget);
  });
}
