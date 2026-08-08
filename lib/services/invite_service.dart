import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/invite_code_model.dart';
import '../data/models/team_model.dart';
import 'firestore_paths.dart';

/// チームID発行・招待コード検証（Aha Moment動線: チームID入力→即開始）
class InviteService {
  final FirebaseFirestore _db;
  InviteService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 紛らわしい文字除外
  static final _random = Random.secure();

  String _generateCode({int length = 8}) {
    // Random.secure()で_codeChars(32文字)全体から直接選ぶ。
    // 旧実装はUUID文字列(16進数=16種)を32で剰余していたため実質16文字しか出現せず、
    // コード空間が意図の半分(16^8)に縮小していた。
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_codeChars[_random.nextInt(_codeChars.length)]);
    }
    return buffer.toString();
  }

  Future<InviteCode> issueInviteCode({
    required String companyId,
    required String teamId,
  }) async {
    InviteCode code;
    DocumentReference<Map<String, dynamic>> ref;
    // 衝突（極めて低確率）を避けるため既存チェック
    while (true) {
      final candidate = _generateCode();
      ref = _db.collection(FirestorePaths.inviteCodes).doc(candidate);
      if (!(await ref.get()).exists) {
        code = InviteCode(
          code: candidate,
          companyId: companyId,
          teamId: teamId,
          isActive: true,
          createdAt: DateTime.now(),
        );
        break;
      }
    }
    await ref.set(code.toMap());
    return code;
  }

  Future<InviteCode?> resolveInviteCode(String code) async {
    final doc =
        await _db.collection(FirestorePaths.inviteCodes).doc(code.toUpperCase()).get();
    if (!doc.exists) return null;
    return InviteCode.fromMap(doc.id, doc.data()!);
  }

  Future<Team> createTeam({
    required String companyId,
    required String teamName,
  }) async {
    final ref = _db.collection(FirestorePaths.teams(companyId)).doc();
    final team = Team(
      id: ref.id,
      companyId: companyId,
      teamName: teamName,
      createdAt: DateTime.now(),
    );
    await ref.set(team.toMap());
    return team;
  }

  Future<void> deactivateInviteCode(String code) async {
    await _db
        .collection(FirestorePaths.inviteCodes)
        .doc(code.toUpperCase())
        .update({'isActive': false});
  }
}
