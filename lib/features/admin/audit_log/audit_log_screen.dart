import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/report_data.dart';
import '../../../core/report_writers.dart';
import '../../../data/models/audit_log_model.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../services/firestore_paths.dart';
import '../../../widgets/error_retry_view.dart';

/// 操作履歴(監査ログ、管理者のみ)。メンバー・会社設定・チームの変更を、誰がいつ行ったかを確認できる。
/// 記録はサーバーが行い、アプリからは変更できない。
class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  static const _limit = 300;
  AuditCategory _category = AuditCategory.all;
  bool _busy = false;

  String _dateTime(DateTime d) =>
      '${ReportBuilder.formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> _exportExcel(List<AuditLog> logs) async {
    if (_busy || logs.isEmpty) return;
    setState(() => _busy = true);
    try {
      final company = ref.read(sessionProvider).company!;
      final now = DateTime.now();
      final data = ReportData(
        companyName: company.name,
        generatedAt: now,
        summary: [
          MapEntry('会社名', company.name),
          MapEntry('出力日', ReportBuilder.formatDate(now)),
          MapEntry('対象', _category.label),
          MapEntry('件数', '${logs.length}件'),
        ],
        tables: [
          ReportTable(
            title: '操作履歴',
            headers: const ['日時', '操作した人', '内容', '種類'],
            rows: [
              for (final l in logs) [_dateTime(l.at), l.actorName, l.summary, l.action],
            ],
          ),
        ],
      );
      final Uint8List bytes = buildReportXlsx(data);
      final dir = await getTemporaryDirectory();
      final name = 'safy_audit_log_${ReportBuilder.formatDate(now).replaceAll('-', '')}.xlsx';
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        subject: name,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('出力に失敗しました')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final company = session.company;
    if (!session.isSignedIn || !session.isAdmin || company == null) {
      return const Scaffold(body: Center(child: Text('管理者のみ利用できます')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('操作履歴')),
      body: StreamBuilder<List<AuditLog>>(
        stream: ref
            .watch(firestoreProvider)
            .collection(FirestorePaths.auditLogs(company.id))
            .orderBy('at', descending: true)
            .limit(_limit)
            .snapshots()
            .map((s) => s.docs.map((d) => AuditLog.fromMap(d.id, d.data())).toList()),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const ErrorRetryView(message: '操作履歴の読み込みに失敗しました');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final logs = snapshot.data!.where(_category.matches).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final c in AuditCategory.values)
                      ChoiceChip(
                        label: Text(c.label),
                        selected: _category == c,
                        onSelected: (_) => setState(() => _category = c),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${logs.length}件(新しい順・最大$_limit件)', style: Theme.of(context).textTheme.bodySmall),
                    ),
                    TextButton.icon(
                      onPressed: (_busy || logs.isEmpty) ? null : () => _exportExcel(logs),
                      icon: const Icon(Icons.grid_on, size: 18),
                      label: const Text('Excelで出力'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: logs.isEmpty
                    ? const Center(child: Text('操作履歴はまだありません'))
                    : ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final l = logs[i];
                          return ListTile(
                            leading: Icon(_icon(l.targetType)),
                            title: Text(l.summary),
                            subtitle: Text('${_dateTime(l.at)}  ・  ${l.actorName}', style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  '操作履歴はサーバーが自動で記録します。管理者でも、記録の変更・削除はできません。',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _icon(String targetType) => switch (targetType) {
        'member' => Icons.person_outline,
        'team' => Icons.groups_2_outlined,
        'company' => Icons.business_outlined,
        _ => Icons.history,
      };
}
