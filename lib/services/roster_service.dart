import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/roster_import.dart';
import 'firestore_paths.dart';

/// 名簿の1件(コード発行済みの社員)。
class RosterEntry {
  final String code;
  final String name;
  final String teamName;
  final String? jobRole;
  final String status; // pending(未参加) / joined(参加済み) / revoked(取消)

  const RosterEntry({
    required this.code,
    required this.name,
    required this.teamName,
    required this.jobRole,
    required this.status,
  });

  factory RosterEntry.fromMap(String code, Map<String, dynamic> m) => RosterEntry(
        code: code,
        name: m['name'] as String? ?? '',
        teamName: m['teamName'] as String? ?? '',
        jobRole: m['jobRole'] as String?,
        status: m['status'] as String? ?? 'pending',
      );

  String get statusLabel => switch (status) {
        'joined' => '参加済み',
        'revoked' => '取消済み',
        _ => '未参加',
      };
}

/// 社員の一括登録(名簿)。コードの発行・取消は席数の確認が必要なため、Cloud Functionsで行う。
class RosterService {
  final FirebaseFirestore _db;
  final FirebaseFunctions? _functionsOverride;

  RosterService([FirebaseFirestore? db, FirebaseFunctions? functions])
      : _db = db ?? FirebaseFirestore.instance,
        _functionsOverride = functions;

  FirebaseFunctions get _functions => _functionsOverride ?? FirebaseFunctions.instance;

  Stream<List<RosterEntry>> watch(String companyId) => _db
      .collection(FirestorePaths.roster(companyId))
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => RosterEntry.fromMap(d.id, d.data())).toList());

  /// 名簿を登録し、1人ごとのコードを受け取る。
  Future<List<RosterEntry>> create({required String companyId, required List<RosterRow> rows}) async {
    final result = await _functions.httpsCallable('createRoster').call<Map<String, dynamic>>({
      'companyId': companyId,
      'entries': [for (final r in rows) r.toMap()],
    });
    final list = (result.data['entries'] as List).cast<Map>();
    return [
      for (final e in list)
        RosterEntry(
          code: e['code'] as String,
          name: e['name'] as String,
          teamName: e['teamName'] as String,
          jobRole: e['jobRole'] as String?,
          status: 'pending',
        ),
    ];
  }

  Future<void> revoke({required String companyId, required String code}) async {
    await _functions.httpsCallable('revokeRosterEntry').call<Map<String, dynamic>>({
      'companyId': companyId,
      'code': code,
    });
  }
}
