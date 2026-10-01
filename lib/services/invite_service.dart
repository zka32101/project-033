import 'dart:math';
import '../core/editor_stamp.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  /// チームの招待コードを発行する。コードはチームごとに一度だけ発行でき、再発行はできない。
  /// すでに発行済みの場合は、新しいコードを作らず、発行済みのコードを返す。
  Future<InviteCode> issueInviteCode({
    required String companyId,
    required String teamId,
  }) async {
    final teamRef = _db.doc('${FirestorePaths.teams(companyId)}/$teamId');
    // 衝突（極めて低確率）を避けるため既存チェック
    String candidate;
    while (true) {
      candidate = _generateCode();
      if (!(await _db.collection(FirestorePaths.inviteCodes).doc(candidate).get()).exists) {
        break;
      }
    }
    final codeRef = _db.collection(FirestorePaths.inviteCodes).doc(candidate);
    return _db.runTransaction<InviteCode>((tx) async {
      final teamSnap = await tx.get(teamRef);
      final existing = teamSnap.data()?['inviteCode'] as String?;
      if (existing != null && existing.isNotEmpty) {
        final existingSnap =
            await tx.get(_db.collection(FirestorePaths.inviteCodes).doc(existing));
        if (existingSnap.exists) {
          return InviteCode.fromMap(existing, existingSnap.data()!);
        }
      }
      final code = InviteCode(
        code: candidate,
        companyId: companyId,
        teamId: teamId,
        isActive: true,
        createdAt: DateTime.now(),
      );
      tx.set(codeRef, code.toMap());
      tx.update(teamRef, {'inviteCode': candidate, ...EditorStamp.fields()});
      return code;
    });
  }

  /// 参加前に、招待コードの会社名・チーム名を確認する(会社情報は参加前は直接読めないため、
  /// Cloud Functions経由で必要な項目だけを取得する)。
  Future<InvitePreview> previewInviteCode(String code) async {
    final result = await FirebaseFunctions.instance
        .httpsCallable('previewInviteCode')
        .call<Map<String, dynamic>>({'inviteCode': code});
    final data = Map<String, dynamic>.from(result.data as Map);
    return InvitePreview(
      companyName: data['companyName'] as String? ?? '',
      teamName: data['teamName'] as String? ?? '',
    );
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
    await ref.set({...team.toMap(), ...EditorStamp.fields()});
    return team;
  }

  Future<void> deactivateInviteCode(String code) async {
    await _db
        .collection(FirestorePaths.inviteCodes)
        .doc(code.toUpperCase())
        .update({'isActive': false});
  }
}

/// 参加前に確認する、招待コードの会社名・チーム名。
class InvitePreview {
  final String companyName;
  final String teamName;

  const InvitePreview({required this.companyName, required this.teamName});
}
