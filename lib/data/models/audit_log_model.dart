import 'firestore_date_parser.dart';

/// 操作履歴(監査ログ)1件。サーバー(Cloud Functions)が記録する。
class AuditLog {
  final String id;
  final DateTime at;
  final String actorId; // 操作した人のuid。サーバーによる変更は 'system'
  final String actorName;
  final String action; // 例: member.promoted
  final String summary; // 画面に表示する説明
  final String targetType; // member / company / team
  final String targetId;

  const AuditLog({
    required this.id,
    required this.at,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.summary,
    required this.targetType,
    required this.targetId,
  });

  factory AuditLog.fromMap(String id, Map<String, dynamic> map) {
    return AuditLog(
      id: id,
      at: parseFirestoreDateTime(map['at']),
      actorId: map['actorId'] as String? ?? 'system',
      actorName: map['actorName'] as String? ?? 'システム',
      action: map['action'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      targetType: map['targetType'] as String? ?? '',
      targetId: map['targetId'] as String? ?? '',
    );
  }
}

/// 操作履歴の絞り込み(対象の種類)。
enum AuditCategory {
  all('すべて', null),
  member('メンバー', 'member'),
  company('会社設定', 'company'),
  team('チーム', 'team');

  final String label;
  final String? targetType;

  const AuditCategory(this.label, this.targetType);

  bool matches(AuditLog log) => targetType == null || log.targetType == targetType;
}
