import '../data/models/completion_certificate_model.dart';
import '../data/models/employee_model.dart';
import 'report_data.dart';

/// 修了証を絞り込む期間。
enum CertificatePeriod {
  all('全期間'),
  thisMonth('今月'),
  lastMonth('先月'),
  last3Months('過去3か月'),
  last12Months('過去12か月');

  final String label;

  const CertificatePeriod(this.label);

  /// 期間の範囲(開始以上・終了未満)。nullは制限なし。
  ({DateTime? from, DateTime? to}) range(DateTime now) {
    switch (this) {
      case CertificatePeriod.all:
        return (from: null, to: null);
      case CertificatePeriod.thisMonth:
        return (from: DateTime(now.year, now.month), to: DateTime(now.year, now.month + 1));
      case CertificatePeriod.lastMonth:
        return (from: DateTime(now.year, now.month - 1), to: DateTime(now.year, now.month));
      case CertificatePeriod.last3Months:
        return (from: DateTime(now.year, now.month - 2), to: DateTime(now.year, now.month + 1));
      case CertificatePeriod.last12Months:
        return (from: DateTime(now.year, now.month - 11), to: DateTime(now.year, now.month + 1));
    }
  }
}

/// 出力する修了証1件(社員名・研修名を解決済み)。
class CertificateEntry {
  final String employeeId;
  final String employeeName;
  final String teamId;
  final String moduleTitle;
  final int score;
  final int thresholdApplied;
  final DateTime issuedAt;

  const CertificateEntry({
    required this.employeeId,
    required this.employeeName,
    required this.teamId,
    required this.moduleTitle,
    required this.score,
    required this.thresholdApplied,
    required this.issuedAt,
  });
}

/// 修了証を、期間・チームで絞り込み、一覧(Excel/CSV/PDF)にまとめる純粋ロジック。
class CertificateBook {
  const CertificateBook._();

  /// [teamId]がnullなら全チーム。退職などで無効化された社員の修了証も、監査証跡として含める。
  /// 新しい順(同日は氏名順)に並べる。
  static List<CertificateEntry> entries({
    required List<CompletionCertificate> certificates,
    required List<Employee> employees,
    required Map<String, String> moduleTitles,
    required CertificatePeriod period,
    String? teamId,
    required DateTime now,
  }) {
    final byId = {for (final e in employees) e.id: e};
    final range = period.range(now);
    final result = <CertificateEntry>[];
    for (final c in certificates) {
      if (range.from != null && c.issuedAt.isBefore(range.from!)) continue;
      if (range.to != null && !c.issuedAt.isBefore(range.to!)) continue;
      final emp = byId[c.employeeId];
      if (teamId != null && emp?.teamId != teamId) continue;
      result.add(CertificateEntry(
        employeeId: c.employeeId,
        employeeName: emp?.displayName ?? '(削除済みの社員)',
        teamId: emp?.teamId ?? '',
        moduleTitle: moduleTitles[c.moduleId] ?? c.moduleId,
        score: c.score,
        thresholdApplied: c.thresholdApplied,
        issuedAt: c.issuedAt,
      ));
    }
    result.sort((a, b) {
      final byDate = b.issuedAt.compareTo(a.issuedAt);
      return byDate != 0 ? byDate : a.employeeName.compareTo(b.employeeName);
    });
    return result;
  }

  /// 受講記録台帳(修了者一覧)。Excel/CSV/PDFの共通データ。
  static ReportData report({
    required List<CertificateEntry> entries,
    required String companyName,
    required String periodLabel,
    required String teamLabel,
    required Map<String, String> teamNames,
    required DateTime now,
  }) {
    final people = entries.map((e) => e.employeeId).toSet().length;
    return ReportData(
      companyName: companyName,
      generatedAt: now,
      summary: [
        MapEntry('会社名', companyName),
        MapEntry('出力日', ReportBuilder.formatDate(now)),
        MapEntry('対象期間', periodLabel),
        MapEntry('対象チーム', teamLabel),
        MapEntry('修了証の件数', '${entries.length}件'),
        MapEntry('修了した社員数', '$people名'),
      ],
      tables: [
        ReportTable(
          title: '修了者一覧',
          headers: const ['氏名', 'チーム', '研修', '修了日', 'スコア', '合格ライン'],
          rows: [
            for (final e in entries)
              [
                e.employeeName,
                e.teamId.isEmpty ? '未所属' : (teamNames[e.teamId] ?? e.teamId),
                e.moduleTitle,
                ReportBuilder.formatDate(e.issuedAt),
                '${e.score}',
                '${e.thresholdApplied}',
              ],
          ],
        ),
      ],
    );
  }
}
