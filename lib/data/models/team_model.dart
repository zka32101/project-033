import 'firestore_date_parser.dart';

class Team {
  final String id;
  final String companyId;
  final String teamName;
  final DateTime createdAt;

  const Team({
    required this.id,
    required this.companyId,
    required this.teamName,
    required this.createdAt,
  });

  factory Team.fromMap(String id, Map<String, dynamic> map) {
    return Team(
      id: id,
      companyId: map['companyId'] as String? ?? '',
      teamName: map['teamName'] as String? ?? '',
      createdAt: parseFirestoreDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'companyId': companyId,
        'teamName': teamName,
        'createdAt': createdAt,
      };

  Team copyWith({String? teamName}) {
    return Team(
      id: id,
      companyId: companyId,
      teamName: teamName ?? this.teamName,
      createdAt: createdAt,
    );
  }
}
