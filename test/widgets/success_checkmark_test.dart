import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/widgets/success_checkmark.dart';

void main() {
  testWidgets('SuccessCheckmark renders and completes its animation', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SuccessCheckmark())),
    );

    expect(find.byType(SuccessCheckmark), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CustomPaint), findsWidgets);
  });
}
