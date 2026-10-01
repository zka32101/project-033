import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/features/billing/contract_guide_screen.dart';
import 'package:safy/providers/session_provider.dart';

class _Session extends SessionNotifier {
  _Session(EmployeeRole role, Company company) {
    state = SessionState(
      employee: Employee(
        id: 'e',
        companyId: 'c',
        teamId: 't',
        displayName: 'テスト',
        role: role,
        createdAt: DateTime(2026, 1, 1),
      ),
      company: company,
    );
  }
}

Company _expiredTrial() => Company(
  id: 'c',
  name: 'n',
  industryId: 'i',
  planType: PlanType.trial,
  contractedHeadcount: 5,
  customPassThreshold: const {},
  createdAt: DateTime(2026, 1, 1),
  trialEndsAt: DateTime(2026, 1, 15),
);

Widget _app(EmployeeRole role) => ProviderScope(
  overrides: [
    sessionProvider.overrideWith((ref) => _Session(role, _expiredTrial())),
  ],
  child: const MaterialApp(home: ContractGuideScreen()),
);

void main() {
  testWidgets('管理者は内容を理解したにチェックするまで申込ボタンが押せない', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(EmployeeRole.admin));
    expect(find.text('お試し期間は終了しました'), findsOneWidget);
    expect(find.text('請求書払い(Web)'), findsOneWidget);
    expect(find.text('ストア課金(Google Play)'), findsOneWidget);

    final button = find.widgetWithText(FilledButton, '請求書払いで申し込む');
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('メンバーには申込ボタンを出さず、管理者への案内を表示する', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(EmployeeRole.member));
    expect(find.byType(FilledButton), findsNothing);
    expect(find.textContaining('会社の管理者のみ行えます'), findsOneWidget);
  });

  testWidgets('申込ボタンで人数入力ダイアログが開き、範囲外の人数では進めない', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(EmployeeRole.admin));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '請求書払いで申し込む'));
    await tester.pumpAndSettle();

    expect(find.text('ご利用人数'), findsOneWidget);
    final go = find.widgetWithText(FilledButton, '決済ページへ');
    expect(tester.widget<FilledButton>(go).onPressed, isNotNull); // 初期値5名

    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    expect(tester.widget<FilledButton>(go).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '1001');
    await tester.pump();
    expect(tester.widget<FilledButton>(go).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '20');
    await tester.pump();
    expect(tester.widget<FilledButton>(go).onPressed, isNotNull);
  });
}
