import 'firestore_date_parser.dart';

class InviteCode {
  final String code;
  final String companyId;
  final String teamId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const InviteCode({
    required this.code,
    required this.companyId,
    required this.teamId,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
  });

  bool isValidNow(DateTime now) {
    if (!isActive) return false;
    if (expiresAt != null && now.isAfter(expiresAt!)) return false;
    return true;
  }

  factory InviteCode.fromMap(String code, Map<String, dynamic> map) {
    return InviteCode(
      code: code,
      companyId: map['companyId'] as String? ?? '',
      teamId: map['teamId'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: parseFirestoreDateTime(map['createdAt']),
      expiresAt: parseFirestoreDateTimeOrNull(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'companyId': companyId,
        'teamId': teamId,
        'isActive': isActive,
        'createdAt': createdAt,
        'expiresAt': expiresAt,
      };
}
