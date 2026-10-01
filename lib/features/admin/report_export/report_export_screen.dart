import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/report_data.dart';
import '../../../core/report_writers.dart';
import '../../../core/required_modules.dart';
import 'certificates_export_screen.dart';
import '../../../data/models/team_model.dart';
import '../../../providers/firebase_providers.dart';
import '../../../services/firestore_paths.dart';
import '../../../data/seed/compliance_checklist_seed.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../widgets/error_retry_view.dart';

/// レポート出力(Excel/PDF/CSV、設計書 Must③・法令対応エビデンス)。
/// 履修状況(社員別・モジュール別)と法令対応チェックリストを、サマリ付きで出力する。
class ReportExportScreen extends ConsumerStatefulWidget {
  const ReportExportScreen({super.key});

  @override
  ConsumerState<ReportExportScreen> createState() => _ReportExportScreenState();
}

class _ReportExportScreenState extends ConsumerState<ReportExportScreen> {
  late Future<ReportData> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ReportData> _load() async {
    final company = ref.read(sessionProvider).company!;
    final employees = await ref
        .read(employeeServiceProvider)
        .watchCompanyEmployees(company.id)
        .first;
    final enrollments = await ref
        .read(enrollmentServiceProvider)
        .watchCompanyEnrollments(company.id)
        .first;
    final content = ref.read(contentServiceProvider);
    final industry = await content.getIndustry(company.industryId);
    final modules = industry == null
        ? <dynamic>[]
        : await content.listModulesForIndustry(
            industry,
            categoryPriorityOverride: company.categoryPriorityOverride,
          );
    final teams = await ref
        .read(firestoreProvider)
        .collection(FirestorePaths.teams(company.id))
        .get();
    final teamExtras = {
      for (final d in teams.docs) d.id: Team.fromMap(d.id, d.data()).assignedModuleIds,
    };
    final statuses = await ref
        .read(complianceChecklistServiceProvider)
        .watchStatuses(company.id)
        .first;
    return ReportBuilder.build(
      company: company,
      employees: employees,
      enrollments: enrollments,
      modules: modules.cast(),
      requiredFor: (e) => RequiredModules.forEmployee(
        companyAssigned: company.assignedModuleIds,
        teamExtra: teamExtras[e.teamId] ?? const [],
        roleExtra: company.roleAssignments[e.jobRole] ?? const [],
      ),
      checklistItems: seedComplianceItems,
      checklistStatuses: statuses,
      now: DateTime.now(),
    );
  }

  String _fileName(ReportData data, String ext) =>
      'safy_report_${ReportBuilder.formatDate(data.generatedAt).replaceAll('-', '')}.$ext';

  Future<void> _share(
    ReportData data,
    Uint8List bytes,
    String ext,
    String mime,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_fileName(data, ext)}');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([
      XFile(file.path, mimeType: mime),
    ], subject: '${data.companyName} 履修状況レポート');
  }

  Future<void> _export(ReportData data, String kind) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      switch (kind) {
        case 'xlsx':
          await _share(
            data,
            buildReportXlsx(data),
            'xlsx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );
        case 'pdf':
          // 日本語フォントは初回のみネットワークから取得して端末にキャッシュされる。
          final base = await PdfGoogleFonts.notoSansJPRegular();
          final bold = await PdfGoogleFonts.notoSansJPBold();
          await _share(
            data,
            await buildReportPdf(data, base: base, bold: bold),
            'pdf',
            'application/pdf',
          );
        case 'csv':
          await _share(data, buildReportCsv(data), 'csv', 'text/csv');
      }
    } catch (_) {
      if (mounted) {
        final hint = kind == 'pdf' ? '(初回はフォント取得のためネットワーク接続が必要です)' : '';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('出力に失敗しました$hint')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('レポート出力')),
      body: FutureBuilder<ReportData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorRetryView(
              message: '履修状況の集計に失敗しました',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('サマリ', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (final e in data.summary)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: Text(e.key)),
                              Expanded(
                                flex: 4,
                                child: Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '出力内容: ${data.tables.map((t) => t.title).join('・')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CertificatesExportScreen()),
                ),
                icon: const Icon(Icons.verified_outlined),
                label: const Text('修了証・受講記録の出力へ'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _busy ? null : () => _export(data, 'xlsx'),
                icon: const Icon(Icons.grid_on),
                label: const Text('Excelで出力する(サマリ+3シート)'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _busy ? null : () => _export(data, 'pdf'),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDFで出力する'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _export(data, 'csv'),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('CSVで出力する(社員別のみ)'),
              ),
              if (_busy) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              const SizedBox(height: 16),
              Text(
                '法令対応チェックリストは自己申告の実施状況です。法令への適合を保証するものではありません。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
