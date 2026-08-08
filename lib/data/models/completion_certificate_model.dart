import 'firestore_date_parser.dart';

/// 監査証跡。どの合格ラインで合格したかをthresholdAppliedとして記録し、
/// 後日の基準変更があっても過去の合格実績の正当性を証明できるようにする。
class CompletionCertificate {
  final String id;
  final String employeeId;
  final String companyId;
  final String moduleId;
  final int score;
  final int thresholdApplied;
  final DateTime issuedAt;

  const CompletionCertificate({
    required this.id,
    required this.employeeId,
    required this.companyId,
    required this.moduleId,
    required this.score,
    required this.thresholdApplied,
    required this.issuedAt,
  });

  factory CompletionCertificate.fromMap(String id, Map<String, dynamic> map) {
    return CompletionCertificate(
      id: id,
      employeeId: map['employeeId'] as String? ?? '',
      companyId: map['companyId'] as String? ?? '',
      moduleId: map['moduleId'] as String? ?? '',
      score: (map['score'] as num?)?.toInt() ?? 0,
      thresholdApplied: (map['thresholdApplied'] as num?)?.toInt() ?? 80,
      issuedAt: parseFirestoreDateTime(map['issuedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'employeeId': employeeId,
        'companyId': companyId,
        'moduleId': moduleId,
        'score': score,
        'thresholdApplied': thresholdApplied,
        'issuedAt': issuedAt,
      };
}
