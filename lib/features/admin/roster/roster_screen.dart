import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/report_data.dart';
import '../../../core/report_writers.dart';
import '../../../core/roster_import.dart';
import '../../../data/models/job_role.dart';
import '../../../data/models/team_model.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/service_providers.dart';
import '../../../providers/session_provider.dart';
import '../../../services/firestore_paths.dart';
import '../../../services/roster_service.dart';
import '../../../widgets/error_retry_view.dart';

/// 社員の一括登録(管理者のみ)。名簿を貼り付けて、1人ごとの招待コードを発行する。
/// 社員がそのコードで参加すると、名簿どおりの名前・チーム・職種で登録される。
class RosterScreen extends ConsumerStatefulWidget {
  const RosterScreen({super.key});

  @override
  ConsumerState<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends ConsumerState<RosterScreen> {
  final _controller = TextEditingController();
  RosterParseResult? _parsed;
  List<String> _serverErrors = const [];
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<Set<String>> _teamNames(String companyId) async {
    final snap = await ref.read(firestoreProvider).collection(FirestorePaths.teams(companyId)).get();
    return {for (final d in snap.docs) Team.fromMap(d.id, d.data()).teamName};
  }

  Future<void> _check() async {
    final company = ref.read(sessionProvider).company!;
    final names = await _teamNames(company.id);
    setState(() {
      _serverErrors = const [];
      _parsed = RosterImport.parse(_controller.text, teamNames: names);
    });
  }

  Future<void> _register(List<RosterRow> rows) async {
    if (_busy) return;
    final company = ref.read(sessionProvider).company!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${rows.length}人分の招待コードを発行しますか?'),
        content: const Text('発行すると、その人数分の席が確保されます。コードは1人1回だけ使えます(取り消すこともできます)。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('発行する')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      final entries = await ref.read(rosterServiceProvider).create(companyId: company.id, rows: rows);
      if (!mounted) return;
      setState(() {
        _parsed = null;
        _serverErrors = const [];
        _controller.clear();
      });
      _toast('${entries.length}人分のコードを発行しました');
      await _exportCodes(company.name, entries);
    } on FirebaseFunctionsException catch (e) {
      if (mounted) setState(() => _serverErrors = (e.message ?? '登録に失敗しました').split('\n'));
    } catch (_) {
      _toast('登録に失敗しました。時間をおいてお試しください');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCodes(String companyName, List<RosterEntry> entries) async {
    try {
      final now = DateTime.now();
      final data = ReportData(
        companyName: companyName,
        generatedAt: now,
        summary: [
          MapEntry('会社名', companyName),
          MapEntry('出力日', ReportBuilder.formatDate(now)),
          MapEntry('人数', '${entries.length}人'),
        ],
        tables: [
          ReportTable(
            title: '招待コード',
            headers: const ['名前', 'チーム', '職種', '招待コード', '状態'],
            rows: [
              for (final e in entries)
                [e.name, e.teamName, JobRole.labelOf(e.jobRole) ?? '', e.code, e.statusLabel],
            ],
          ),
        ],
      );
      final Uint8List bytes = buildReportXlsx(data);
      final dir = await getTemporaryDirectory();
      final name = 'safy_invite_codes_${ReportBuilder.formatDate(now).replaceAll('-', '')}.xlsx';
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
        subject: name,
      );
    } catch (_) {
      _toast('一覧の出力に失敗しました。下の一覧からコードを確認できます');
    }
  }

  Future<void> _revoke(RosterEntry e) async {
    final company = ref.read(sessionProvider).company!;
    try {
      await ref.read(rosterServiceProvider).revoke(companyId: company.id, code: e.code);
      _toast('${e.name}さんのコードを取り消しました');
    } on FirebaseFunctionsException catch (ex) {
      _toast(ex.message ?? '取り消しに失敗しました');
    } catch (_) {
      _toast('取り消しに失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final company = session.company;
    if (!session.isSignedIn || !session.isAdmin || company == null) {
      return const Scaffold(body: Center(child: Text('管理者のみ利用できます')));
    }
    final parsed = _parsed;
    return Scaffold(
      appBar: AppBar(title: const Text('社員の一括登録')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '名簿を貼り付けると、1人ごとの招待コードを発行します。'
            '社員はそのコードを入力するだけで、名前・チーム・職種が設定された状態で参加できます。',
          ),
          const SizedBox(height: 8),
          Text(
            '1行に1人。「名前, チーム名, 職種(任意)」の順に、カンマまたはタブで区切ります(Excelからコピーしてそのまま貼り付けられます)。'
            'チームは先にチーム管理で作成してください。職種は ${JobRole.all.map((r) => r.label).join('・')} から選べます。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 5,
            maxLines: 12,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '佐藤 花子, 営業部, 営業\n鈴木 一郎, 総務部, 人事・総務',
            ),
            onChanged: (_) => setState(() {
              _parsed = null;
              _serverErrors = const [];
            }),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: _controller.text.trim().isEmpty || _busy ? null : _check,
              child: const Text('内容を確認する'),
            ),
          ),
          if (parsed != null) ...[
            const SizedBox(height: 12),
            if (parsed.errors.isNotEmpty)
              _ErrorBox(lines: parsed.errors.take(10).toList(), more: parsed.errors.length - 10)
            else ...[
              Text('${parsed.rows.length}人を登録できます', style: const TextStyle(fontWeight: FontWeight.bold)),
              for (final r in parsed.rows.take(5))
                Text('・${r.name}(${r.teamName}${r.jobRole == null ? '' : '・${JobRole.labelOf(r.jobRole)}'})'),
              if (parsed.rows.length > 5) Text('ほか${parsed.rows.length - 5}人'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busy ? null : () => _register(parsed.rows),
                child: Text(_busy ? '発行中…' : '${parsed.rows.length}人分のコードを発行する'),
              ),
            ],
          ],
          if (_serverErrors.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ErrorBox(lines: _serverErrors, more: 0),
          ],
          const Divider(height: 32),
          Text('発行済みの名簿', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<List<RosterEntry>>(
            stream: ref.watch(rosterServiceProvider).watch(company.id),
            builder: (context, snap) {
              if (snap.hasError) return const ErrorRetryView(message: '名簿の読み込みに失敗しました');
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final entries = snap.data!;
              if (entries.isEmpty) return const Text('まだ名簿はありません');
              final pending = entries.where((e) => e.status == 'pending').length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('未参加$pending人 / 全${entries.length}人', style: Theme.of(context).textTheme.bodySmall),
                  TextButton.icon(
                    onPressed: () => _exportCodes(company.name, entries),
                    icon: const Icon(Icons.grid_on, size: 18),
                    label: const Text('Excelで出力(コード一覧)'),
                  ),
                  for (final e in entries)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(e.name),
                      subtitle: Text(
                        '${e.teamName}${e.jobRole == null ? '' : ' ・ ${JobRole.labelOf(e.jobRole)}'}\n'
                        '${e.status == 'pending' ? 'コード: ${e.code}  ・  ' : ''}${e.statusLabel}',
                      ),
                      isThreeLine: true,
                      trailing: e.status == 'pending'
                          ? TextButton(onPressed: () => _revoke(e), child: const Text('取り消す'))
                          : null,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final List<String> lines;
  final int more;
  const _ErrorBox({required this.lines, required this.more});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: color), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('登録できません。次を直してください', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          for (final l in lines) Text(l),
          if (more > 0) Text('ほか$more件'),
        ],
      ),
    );
  }
}
