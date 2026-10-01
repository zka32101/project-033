import 'firestore_date_parser.dart';

enum EmployeeRole { admin, member }

class Employee {
  final String id;
  final String companyId;
  final String teamId;
  final String displayName;
  final EmployeeRole role;
  final DateTime createdAt;
  final String? jobRole; // JobRole.id。未設定ならnull
  final bool deactivated; // 無効化(退職など)されているか。無効化されるとアプリを使えず、席も空く

  const Employee({
    required this.id,
    required this.companyId,
    required this.teamId,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.jobRole,
    this.deactivated = false,
  });

  factory Employee.fromMap(String id, Map<String, dynamic> map) {
    return Employee(
      id: id,
      companyId: map['companyId'] as String? ?? '',
      teamId: map['teamId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      role: (map['role'] as String?) == 'admin'
          ? EmployeeRole.admin
          : EmployeeRole.member,
      createdAt: parseFirestoreDateTime(map['createdAt']),
      jobRole: map['jobRole'] as String?,
      deactivated: map['deactivated'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'companyId': companyId,
        'teamId': teamId,
        'displayName': displayName,
        'role': role == EmployeeRole.admin ? 'admin' : 'member',
        'createdAt': createdAt,
        if (jobRole != null) 'jobRole': jobRole,
        if (deactivated) 'deactivated': true,
      };

  Employee copyWith({
    String? displayName,
    EmployeeRole? role,
    String? teamId,
    String? jobRole,
    bool clearJobRole = false,
  }) {
    return Employee(
      id: id,
      companyId: companyId,
      teamId: teamId ?? this.teamId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt,
      jobRole: clearJobRole ? null : (jobRole ?? this.jobRole),
    );
  }
}
