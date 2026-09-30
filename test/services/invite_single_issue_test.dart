import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safy/services/invite_service.dart';
import 'package:safy/widgets/role_badge.dart';

void main() {
  test('招待コードはチームごとに一度だけ発行でき、再発行しても同じコードが返る', () async {
    final db = FakeFirebaseFirestore();
    final service = InviteService(db);
    final team = await service.createTeam(companyId: 'c1', teamName: '本社');

    final first = await service.issueInviteCode(companyId: 'c1', teamId: team.id);
    final second = await service.issueInviteCode(companyId: 'c1', teamId: team.id);

    expect(second.code, first.code);
    final codes = await db.collection('inviteCodes').get();
    expect(codes.docs.length, 1);
    final teamDoc = await db.doc('companies/c1/teams/${team.id}').get();
    expect(teamDoc.data()!['inviteCode'], first.code);
  });

  test('別のチームには別の招待コードが発行される', () async {
    final service = InviteService(FakeFirebaseFirestore());
    final a = await service.createTeam(companyId: 'c1', teamName: 'A');
    final b = await service.createTeam(companyId: 'c1', teamName: 'B');
    final codeA = await service.issueInviteCode(companyId: 'c1', teamId: a.id);
    final codeB = await service.issueInviteCode(companyId: 'c1', teamId: b.id);
    expect(codeA.code, isNot(codeB.code));
  });

  testWidgets('役割バッジは管理者と受講者を文言で区別する', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Column(children: [RoleBadge(isAdmin: true), RoleBadge(isAdmin: false)]),
    ));
    expect(find.text('管理者'), findsOneWidget);
    expect(find.text('受講者'), findsOneWidget);
  });
}
