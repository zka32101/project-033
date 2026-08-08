import 'firestore_date_parser.dart';

class ProgressRecord {
  final String id;
  final String employeeId;
  final String moduleId;
  final List<String> completedLessonIds;
  final DateTime lastAccessedAt;

  const ProgressRecord({
    required this.id,
    required this.employeeId,
    required this.moduleId,
    required this.completedLessonIds,
    required this.lastAccessedAt,
  });

  factory ProgressRecord.fromMap(String id, Map<String, dynamic> map) {
    return ProgressRecord(
      id: id,
      employeeId: map['employeeId'] as String? ?? '',
      moduleId: map['moduleId'] as String? ?? '',
      completedLessonIds:
          List<String>.from((map['completedLessonIds'] as List?) ?? []),
      lastAccessedAt: parseFirestoreDateTime(map['lastAccessedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'employeeId': employeeId,
        'moduleId': moduleId,
        'completedLessonIds': completedLessonIds,
        'lastAccessedAt': lastAccessedAt,
      };

  ProgressRecord copyWith({
    List<String>? completedLessonIds,
    DateTime? lastAccessedAt,
  }) {
    return ProgressRecord(
      id: id,
      employeeId: employeeId,
      moduleId: moduleId,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}
