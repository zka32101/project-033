import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/category_model.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/data/models/module_model.dart';
import 'package:safy/features/billing/contract_guide_screen.dart';
import 'package:safy/features/paywall/paywall_screen.dart';
import 'package:safy/providers/session_provider.dart';

class _Session extends SessionNotifier {
  _Session() {
    state = SessionState(
      employee: Employee(
        id: 'e',
        companyId: 'c',
        teamId: 't',
        displayName: 'テスト',
        role: EmployeeRole.admin,
        createdAt: DateTime(2026, 1, 1),
      ),
      company: Company(
        id: 'c',
        name: 'n',
        industryId: 'i',
        planType: PlanType.trial,
        contractedHeadcount: 5,
        customPassThreshold: const {},
        createdAt: DateTime(2026, 1, 1),
        trialEndsAt: DateTime(2026, 1, 15),
      ),
    );
  }
}

void main() {
  testWidgets('ロック画面のボタンは、プランを直接書き換えず契約案内画面へ進む', (tester) async {
    final module = Module(
      id: 'm1',
      categoryId: CategoryId.security,
      title: '有料モジュール',
      description: '説明',
      passThresholdDefault: 80,
      isFreeTrial: false,
      sortOrder: 1,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sessionProvider.overrideWith((ref) => _Session())],
        child: MaterialApp(home: PaywallScreen(module: module)),
      ),
    );

    expect(find.text('有料モジュール'), findsOneWidget);
    expect(find.text('上位プランでこのモジュールを含める'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'ご契約の方法を確認する'));
    await tester.pumpAndSettle();

    expect(find.byType(ContractGuideScreen), findsOneWidget);
    expect(find.text('ご契約について'), findsOneWidget);
  });
}
