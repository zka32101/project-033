import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/completion_certificate_model.dart';
import '../../data/models/module_model.dart';
import '../../providers/service_providers.dart';
import '../../providers/session_provider.dart';
import '../../widgets/error_retry_view.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/empty_state_view.dart';

/// 修了証一覧・PDF出力(設計書 Must⑤: 修了証・受講記録=法令対応エビデンス)。
/// 社員本人が自分の修了証をいつでもダウンロードできるようにする。
class MyCertificatesScreen extends ConsumerWidget {
  const MyCertificatesScreen({super.key});

  Future<void> _downloadPdf({
    required CompletionCertificate certificate,
    required String employeeName,
    required String companyName,
    required String moduleTitle,
  }) async {
    final dateFormat = DateFormat('yyyy年MM月dd日');
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(48),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2, color: PdfColor.fromHex('#2D5F7C')),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('修了証', style: const pw.TextStyle(fontSize: 32)),
                pw.SizedBox(height: 32),
                pw.Text('$employeeName 様', style: const pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 24),
                pw.Text(
                  '上記の方は「$moduleTitle」研修を修了し、',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  '合格ライン${certificate.thresholdApplied}点に対しスコア${certificate.score}点を獲得したことを証します。',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 40),
                pw.Text(dateFormat.format(certificate.issuedAt),
                    style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 8),
                pw.Text(companyName, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 24),
                pw.Text('安心企業研修アンゼット', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'certificate_${certificate.moduleId}.pdf',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (!session.isSignedIn) {
      return const Scaffold(body: Center(child: Text('セッションが見つかりません')));
    }
    final company = session.company!;
    final employee = session.employee!;
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Scaffold(
      appBar: AppBar(title: const Text('修了証')),
      body: StreamBuilder<List<CompletionCertificate>>(
        stream: ref.read(quizServiceProvider).watchCertificates(company.id, employee.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorRetryView(message: '修了証の読み込みに失敗しました');
          }
          if (!snapshot.hasData) {
            return const SkeletonList();
          }
          final certificates = snapshot.data!;
          if (certificates.isEmpty) {
            return const EmptyStateView(
              imagePath: 'assets/images/empty_states/empty_state_no_modules.png',
              message: 'まだ修了した研修がありません',
            );
          }

          return ListView.builder(
            itemCount: certificates.length,
            itemBuilder: (context, index) {
              final certificate = certificates[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.verified_outlined),
                  title: FutureBuilder<Module?>(
                    future: ref.read(contentServiceProvider).getModule(certificate.moduleId),
                    builder: (context, moduleSnapshot) {
                      return Text(moduleSnapshot.data?.title ?? certificate.moduleId);
                    },
                  ),
                  subtitle: Text(
                    '修了日: ${dateFormat.format(certificate.issuedAt)} / スコア: ${certificate.score}点',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download_outlined),
                    tooltip: 'PDFで保存・共有',
                    onPressed: () async {
                      final module =
                          await ref.read(contentServiceProvider).getModule(certificate.moduleId);
                      await _downloadPdf(
                        certificate: certificate,
                        employeeName: employee.displayName,
                        companyName: company.name,
                        moduleTitle: module?.title ?? certificate.moduleId,
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
