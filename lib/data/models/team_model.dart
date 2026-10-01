import 'firestore_date_parser.dart';

class Team {
  final String id;
  final String companyId;
  final String teamName;
  final DateTime createdAt;
  // 発行済みの招待コード。チームごとに一度だけ発行でき、再発行はできない。
  final String? inviteCode;
  // このチームに追加で必須とする研修ID(全社共通の必須に加えて)。
  final List<String> assignedModuleIds;

  const Team({
    required this.id,
    required this.companyId,
    required this.teamName,
    required this.createdAt,
    this.inviteCode,
    this.assignedModuleIds = const [],
  });

  factory Team.fromMap(String id, Map<String, dynamic> map) {
    return Team(
      id: id,
      companyId: map['companyId'] as String? ?? '',
      teamName: map['teamName'] as String? ?? '',
      createdAt: parseFirestoreDateTime(map['createdAt']),
      inviteCode: map['inviteCode'] as String?,
      assignedModuleIds: List<String>.from((map['assignedModuleIds'] as List?) ?? const []),
    );
  }

  Map<String, dynamic> toMap() => {
        'companyId': companyId,
        'teamName': teamName,
        'createdAt': createdAt,
        if (inviteCode != null) 'inviteCode': inviteCode,
        if (assignedModuleIds.isNotEmpty) 'assignedModuleIds': assignedModuleIds,
      };

  Team copyWith({String? teamName}) {
    return Team(
      id: id,
      companyId: companyId,
      teamName: teamName ?? this.teamName,
      createdAt: createdAt,
      inviteCode: inviteCode,
      assignedModuleIds: assignedModuleIds,
    );
  }
}
