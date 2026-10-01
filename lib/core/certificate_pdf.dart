import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'certificate_book.dart';

/// 修了証のPDF。1件につき1ページ(A4)。日本語を表示するため、日本語対応フォントを渡す必要がある。
Future<Uint8List> buildCertificatesPdf(
  List<CertificateEntry> entries, {
  required String companyName,
  required pw.Font base,
  required pw.Font bold,
}) async {
  final doc = pw.Document(theme: pw.ThemeData.withFont(base: base, bold: bold));
  const accent = PdfColor.fromInt(0xFF2D5F7C);

  for (final e in entries) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(48),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 2, color: accent)),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('修了証', style: pw.TextStyle(font: bold, fontSize: 32)),
                pw.SizedBox(height: 32),
                pw.Text('${e.employeeName} 様', style: const pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 24),
                pw.Text('上記の方は「${e.moduleTitle}」研修を修了し、',
                    style: const pw.TextStyle(fontSize: 14), textAlign: pw.TextAlign.center),
                pw.Text(
                  '合格ライン${e.thresholdApplied}点に対しスコア${e.score}点を獲得したことを証します。',
                  style: const pw.TextStyle(fontSize: 14),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 40),
                pw.Text(_jpDate(e.issuedAt), style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 8),
                pw.Text(companyName, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 24),
                pw.Text('安心企業研修Safy', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
  return doc.save();
}

String _jpDate(DateTime d) => '${d.year}年${d.month.toString().padLeft(2, '0')}月${d.day.toString().padLeft(2, '0')}日';
