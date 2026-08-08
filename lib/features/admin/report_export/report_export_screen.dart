import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/dashboard_analytics.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';

/// レポート出力(CSV/PDF、設計書 Must③・法令対応エビデンス)
class ReportExportScreen extends ConsumerWidget {
  const ReportExportScreen({super.key});

  Future<List<EmployeeCompletionStat>> _loadStats(WidgetRef ref, String companyId, String industryId) async {
    final employees = await ref.read(employeeServiceProvider).watchCompanyEmployees(companyId).first;
    final enrollments = await ref.read(enrollmentServiceProvider).watchCompanyEnrollments(companyId).first;
    final industry = await ref.read(contentServiceProvider).getIndustry(industryId);
    final totalModules = industry == null
        ? 0
        : (await ref.read(contentServiceProvider).listModulesForIndustry(industry)).length;
    return DashboardAnalytics.computeEmployeeCompletionStats(
      employees: employees,
      enrollments: enrollments,
      totalModuleCount: totalModules,
    );
  }

  Future<void> _exportPdf(List<EmployeeCompletionStat> stats, String companyName) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('$companyName 履修状況レポート', style: const pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              headers: ['氏名', '完了モジュール数', '対象モジュール数', '受講率(%)'],
              data: stats
                  .map((s) => [
                        s.displayName,
                        s.completedCount.toString(),
                        s.totalModuleCount.toString(),
                        '${s.completionRatePercent}%',
                      ])
                  .toList(),
            ),
          ],
        ),
      ),
    );
    await Printing.sharePdf(bytes: await doc.save(), filename: 'anzet_report.pdf');
  }

  /// 法令監査での二次利用(表計算ソフトでの再集計等)向けにCSVでも出力できるようにする。
  Future<void> _exportCsv(List<EmployeeCompletionStat> stats, String companyName) async {
    final rows = <List<String>>[
      ['氏名', '完了モジュール数', '対象モジュール数', '受講率(%)'],
      ...stats.map((s) => [
            s.displayName,
            s.completedCount.toString(),
            s.totalModuleCount.toString(),
            s.completionRatePercent.toString(),
          ]),
    ];
    final csvContent = const ListToCsvConverter().convert(rows);
    // BOM付きUTF-8で保存し、Excel等で日本語が文字化けしないようにする。
    final bytes = <int>[0xEF, 0xBB, 0xBF, ...utf8.encode(csvContent)];

    final file = File('${Directory.systemTemp.path}/anzet_report.csv');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], subject: '$companyName 履修状況レポート(CSV)');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }
    final company = session.company!;

    return Scaffold(
      appBar: AppBar(title: const Text('レポート出力')),
      body: FutureBuilder<List<EmployeeCompletionStat>>(
        future: _loadStats(ref, company.id, company.industryId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorRetryView(message: '履修状況の集計に失敗しました');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('対象社員数: ${stats.length}名'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await _exportPdf(stats, company.name);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PDF出力に失敗しました')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDFレポートを出力する'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await _exportCsv(stats, company.name);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('CSV出力に失敗しました')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('CSVレポートを出力する'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
