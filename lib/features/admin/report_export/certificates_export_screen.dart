import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/certificate_book.dart';
import '../../../core/certificate_pdf.dart';
import '../../../core/report_data.dart';
import '../../../core/report_writers.dart';
import '../../../data/models/completion_certificate_model.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/models/team_model.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../services/firestore_paths.dart';
import '../../../widgets/error_retry_view.dart';

/// 修了証・受講記録の一括出力(管理者のみ)。期間・チームで絞り込み、
/// 修了証PDF(1人1研修1ページ)と、修了者一覧(Excel/CSV)を出力する。法令対応・監査のエビデンス用。
class CertificatesExportScreen extends ConsumerStatefulWidget {
  const CertificatesExportScreen({super.key});

  @override
  ConsumerState<CertificatesExportScreen> createState() => _CertificatesExportScreenState();
}

class _Loaded {
  final List<CompletionCertificate> certificates;
  final List<Employee> employees;
  final List<Team> teams;
  final Map<String, String> moduleTitles;
  const _Loaded(this.certificates, this.employees, this.teams, this.moduleTitles);
}

class _CertificatesExportScreenState extends ConsumerState<CertificatesExportScreen> {
  late Future<_Loaded> _future;
  CertificatePeriod _period = CertificatePeriod.all;
  String? _teamId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Loaded> _load() async {
    final company = ref.read(sessionProvider).company!;
    final db = ref.read(firestoreProvider);
    final content = ref.read(contentServiceProvider);

    final certSnap = await db.collection(FirestorePaths.certificates(company.id)).get();
    final certificates =
        certSnap.docs.map((d) => CompletionCertificate.fromMap(d.id, d.data())).toList();
    // 退職などで無効化された社員の修了証も、監査証跡として出力するため、無効化済みも含めて読む。
    final employees = await ref.read(memberAdminServiceProvider).watchMembers(company.id).first;
    final teamSnap = await db.collection(FirestorePaths.teams(company.id)).get();
    final teams = teamSnap.docs.map((d) => Team.fromMap(d.id, d.data())).toList();

    final titles = <String, String>{};
    final industry = await content.getIndustry(company.industryId);
    if (industry != null) {
      for (final m in await content.listModulesForIndustry(industry)) {
        titles[m.id] = m.title;
      }
    }
    for (final m in await ref.read(customContentServiceProvider).listCustomModules(company.id)) {
      titles[m.id] = m.title;
    }
    return _Loaded(certificates, employees, teams, titles);
  }

  List<CertificateEntry> _entries(_Loaded d) => CertificateBook.entries(
        certificates: d.certificates,
        employees: d.employees,
        moduleTitles: d.moduleTitles,
        period: _period,
        teamId: _teamId,
        now: DateTime.now(),
      );

  ReportData _report(_Loaded d, List<CertificateEntry> entries) {
    final company = ref.read(sessionProvider).company!;
    final teamNames = {for (final t in d.teams) t.id: t.teamName};
    return CertificateBook.report(
      entries: entries,
      companyName: company.name,
      periodLabel: _period.label,
      teamLabel: _teamId == null ? '全チーム' : (teamNames[_teamId] ?? _teamId!),
      teamNames: teamNames,
      now: DateTime.now(),
    );
  }

  Future<void> _share(Uint8List bytes, String name, String mime) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path, mimeType: mime)], subject: name);
  }

  Future<void> _export(_Loaded d, String kind) async {
    if (_busy) return;
    final entries = _entries(d);
    if (entries.isEmpty) return;
    setState(() => _busy = true);
    try {
      final company = ref.read(sessionProvider).company!;
      final stamp = ReportBuilder.formatDate(DateTime.now()).replaceAll('-', '');
      switch (kind) {
        case 'pdf':
          // 日本語フォントは初回のみネットワークから取得して端末にキャッシュされる。
          final base = await PdfGoogleFonts.notoSansJPRegular();
          final bold = await PdfGoogleFonts.notoSansJPBold();
          await _share(
            await buildCertificatesPdf(entries, companyName: company.name, base: base, bold: bold),
            'safy_certificates_$stamp.pdf',
            'application/pdf',
          );
        case 'xlsx':
          await _share(
            buildReportXlsx(_report(d, entries)),
            'safy_certificate_ledger_$stamp.xlsx',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );
        case 'csv':
          await _share(buildReportCsv(_report(d, entries)), 'safy_certificate_ledger_$stamp.csv', 'text/csv');
      }
    } catch (_) {
      if (mounted) {
        final hint = kind == 'pdf' ? '(初回はフォント取得のためネットワーク接続が必要です)' : '';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('出力に失敗しました$hint')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn || !session.isAdmin) {
      return const Scaffold(body: Center(child: Text('管理者のみ利用できます')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('修了証・受講記録の出力')),
      body: FutureBuilder<_Loaded>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorRetryView(
              message: '修了証の読み込みに失敗しました',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          final entries = _entries(data);
          final canExport = entries.isNotEmpty && !_busy;
          final theme = Theme.of(context);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('出力する範囲', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<CertificatePeriod>(
                key: const Key('period'),
                initialValue: _period,
                decoration: const InputDecoration(labelText: '期間', border: OutlineInputBorder()),
                items: [
                  for (final p in CertificatePeriod.values) DropdownMenuItem(value: p, child: Text(p.label)),
                ],
                onChanged: (v) => setState(() => _period = v ?? CertificatePeriod.all),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const Key('team'),
                initialValue: _teamId,
                decoration: const InputDecoration(labelText: 'チーム', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('全チーム')),
                  for (final t in data.teams) DropdownMenuItem<String?>(value: t.id, child: Text(t.teamName)),
                ],
                onChanged: (v) => setState(() => _teamId = v),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '対象: ${entries.length}件(${entries.map((e) => e.employeeId).toSet().length}名)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              if (entries.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('この条件に当てはまる修了証はありません。', style: TextStyle(fontSize: 12)),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: canExport ? () => _export(data, 'pdf') : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: Text('修了証をPDFで出力(${entries.length}ページ)'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: canExport ? () => _export(data, 'xlsx') : null,
                icon: const Icon(Icons.grid_on),
                label: const Text('修了者一覧をExcelで出力'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: canExport ? () => _export(data, 'csv') : null,
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('修了者一覧をCSVで出力'),
              ),
              if (_busy) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator()),
              ],
              const SizedBox(height: 16),
              Text(
                '退職などで無効化した社員の修了証も、記録として含まれます。',
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}
