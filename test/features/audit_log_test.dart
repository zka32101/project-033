import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/audit_log_model.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/features/admin/audit_log/audit_log_screen.dart';
import 'package:safy/providers/firebase_providers.dart';
import 'package:safy/providers/session_provider.dart';

class _Session extends SessionNotifier {
  _Session(EmployeeRole role) {
    state = SessionState(
      employee: Employee(
        id: 'a1',
        companyId: 'c1',
        teamId: 't',
        displayName: '管理者',
        role: role,
        createdAt: DateTime(2026, 1, 1),
      ),
      company: Company(
        id: 'c1',
        name: 'テスト',
        industryId: 'retail',
        planType: PlanType.trial,
        contractedHeadcount: 5,
        customPassThreshold: const {},
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }
}

Future<FakeFirebaseFirestore> _db() async {
  final db = FakeFirebaseFirestore();
  Future<void> log(String id, DateTime at, String summary, String type, {String actor = '山田'}) =>
      db.doc('companies/c1/auditLogs/$id').set({
        'at': at,
        'actorId': 'u',
        'actorName': actor,
        'action': 'x',
        'summary': summary,
        'targetType': type,
        'targetId': 't',
      });
  await log('l1', DateTime(2026, 10, 1, 9, 5), '佐藤さんを管理者にしました', 'member');
  await log('l2', DateTime(2026, 10, 3, 14, 30), '合格ラインを変更しました', 'company');
  await log('l3', DateTime(2026, 10, 2, 10, 0), 'チーム「営業」の追加の必須研修を変更しました(2件)', 'team', actor: 'システム');
  return db;
}

Widget _app(FakeFirebaseFirestore db, EmployeeRole role) => ProviderScope(
      overrides: [
        firestoreProvider.overrideWithValue(db),
        sessionProvider.overrideWith((ref) => _Session(role)),
      ],
      child: const MaterialApp(home: AuditLogScreen()),
    );

void main() {
  test('AuditLogは保存値から復元でき、欠けた項目は既定値になる', () {
    final l = AuditLog.fromMap('x', {'summary': 's', 'targetType': 'team'});
    expect(l.actorName, 'システム');
    expect(l.actorId, 'system');
    expect(l.summary, 's');
  });

  test('カテゴリの絞り込み', () {
    final member = AuditLog.fromMap('1', {'targetType': 'member'});
    expect(AuditCategory.all.matches(member), isTrue);
    expect(AuditCategory.member.matches(member), isTrue);
    expect(AuditCategory.team.matches(member), isFalse);
  });

  testWidgets('新しい順に表示され、種類で絞り込める', (tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await _db();

    await tester.pumpWidget(_app(db, EmployeeRole.admin));
    await tester.pumpAndSettle();

    expect(find.text('3件(新しい順・最大300件)'), findsOneWidget);
    final titles = tester.widgetList<ListTile>(find.byType(ListTile)).map((t) => (t.title as Text).data).toList();
    expect(titles, [
      '合格ラインを変更しました', // 10/3
      'チーム「営業」の追加の必須研修を変更しました(2件)', // 10/2
      '佐藤さんを管理者にしました', // 10/1
    ]);
    expect(find.text('2026-10-03 14:30  ・  山田'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'メンバー'));
    await tester.pumpAndSettle();
    expect(find.text('1件(新しい順・最大300件)'), findsOneWidget);
    expect(find.text('佐藤さんを管理者にしました'), findsOneWidget);
    expect(find.text('合格ラインを変更しました'), findsNothing);
  });

  testWidgets('履歴がなければ案内を表示する', (tester) async {
    await tester.pumpWidget(_app(FakeFirebaseFirestore(), EmployeeRole.admin));
    await tester.pumpAndSettle();
    expect(find.text('操作履歴はまだありません'), findsOneWidget);
  });

  testWidgets('管理者以外は使えない', (tester) async {
    await tester.pumpWidget(_app(await _db(), EmployeeRole.member));
    await tester.pumpAndSettle();
    expect(find.text('管理者のみ利用できます'), findsOneWidget);
  });
}
