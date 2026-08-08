import 'firestore_date_parser.dart';

enum EnrollmentStatus { notStarted, inProgress, completed }

class Enrollment {
  final String id;
  final String employeeId;
  final String moduleId;
  final EnrollmentStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const Enrollment({
    required this.id,
    required this.employeeId,
    required this.moduleId,
    required this.status,
    this.startedAt,
    this.completedAt,
  });

  factory Enrollment.fromMap(String id, Map<String, dynamic> map) {
    EnrollmentStatus parseStatus(String? v) {
      switch (v) {
        case 'inProgress':
          return EnrollmentStatus.inProgress;
        case 'completed':
          return EnrollmentStatus.completed;
        default:
          return EnrollmentStatus.notStarted;
      }
    }

    return Enrollment(
      id: id,
      employeeId: map['employeeId'] as String? ?? '',
      moduleId: map['moduleId'] as String? ?? '',
      status: parseStatus(map['status'] as String?),
      startedAt: parseFirestoreDateTimeOrNull(map['startedAt']),
      completedAt: parseFirestoreDateTimeOrNull(map['completedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'employeeId': employeeId,
        'moduleId': moduleId,
        'status': status.name,
        'startedAt': startedAt,
        'completedAt': completedAt,
      };

  Enrollment copyWith({
    EnrollmentStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return Enrollment(
      id: id,
      employeeId: employeeId,
      moduleId: moduleId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
