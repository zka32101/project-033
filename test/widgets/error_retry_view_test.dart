import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/widgets/error_retry_view.dart';

void main() {
  testWidgets('メッセージを表示する', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ErrorRetryView(message: 'エラーが発生しました')),
      ),
    );

    expect(find.text('エラーが発生しました'), findsOneWidget);
    expect(find.text('再読み込み'), findsNothing);
  });

  testWidgets('onRetryを渡すと再読み込みボタンが表示されタップで呼ばれる', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorRetryView(
            message: 'エラーが発生しました',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('再読み込み'), findsOneWidget);
    await tester.tap(find.text('再読み込み'));
    expect(retried, isTrue);
  });
}
