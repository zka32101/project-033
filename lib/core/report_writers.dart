import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'report_data.dart';

/// ReportDataをExcel(.xlsx)にする。1枚目がサマリ、以降は表ごとに1シート。
Uint8List buildReportXlsx(ReportData data) {
  final excel = Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet();

  final header = CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.fromHexString('#E8EEF7'),
  );

  final summary = excel['サマリ'];
  summary.appendRow([TextCellValue('安心企業研修Safy 履修状況レポート')]);
  summary
      .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
      .cellStyle = CellStyle(
    bold: true,
    fontSize: 14,
  );
  summary.appendRow([TextCellValue('')]);
  for (final entry in data.summary) {
    summary.appendRow([TextCellValue(entry.key), TextCellValue(entry.value)]);
    summary
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 0,
                rowIndex: summary.maxRows - 1,
              ),
            )
            .cellStyle =
        header;
  }
  summary.setColumnWidth(0, 30);
  summary.setColumnWidth(1, 40);

  for (final table in data.tables) {
    // シート名は31文字以内・一部の記号が使えない制約があるため、表のタイトルはそれに収める。
    final sheet = excel[table.title];
    sheet.appendRow(table.headers.map((h) => TextCellValue(h)).toList());
    for (var c = 0; c < table.headers.length; c++) {
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
              .cellStyle =
          header;
      sheet.setColumnWidth(c, _columnWidth(table, c));
    }
    for (final row in table.rows) {
      sheet.appendRow(row.map((v) => TextCellValue(v)).toList());
    }
  }

  excel.setDefaultSheet('サマリ');
  if (defaultSheet != null && defaultSheet != 'サマリ') excel.delete(defaultSheet);

  final bytes = excel.save();
  if (bytes == null) throw StateError('Excelファイルの生成に失敗しました');
  return Uint8List.fromList(bytes);
}

double _columnWidth(ReportTable table, int column) {
  var longest = table.headers[column].length;
  for (final row in table.rows) {
    if (row[column].length > longest) longest = row[column].length;
  }
  // 日本語は全角で幅を取るため少し広めにする(最大60)。
  return (longest * 2.0 + 2).clamp(10, 60).toDouble();
}

/// ReportDataをPDFにする。日本語を表示するため、日本語対応フォントを渡す必要がある。
Future<Uint8List> buildReportPdf(
  ReportData data, {
  required pw.Font base,
  required pw.Font bold,
}) async {
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: base, bold: bold),
  );
  const tableHeaderColor = PdfColor.fromInt(0xFFE8EEF7);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${ctx.pageNumber} / ${ctx.pagesCount}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
      build: (ctx) => [
        pw.Text('履修状況レポート', style: pw.TextStyle(font: bold, fontSize: 20)),
        pw.SizedBox(height: 4),
        pw.Text(
          '${data.companyName}  /  ${ReportBuilder.formatDate(data.generatedAt)} 出力',
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: 16),
        pw.Text('サマリ', style: pw.TextStyle(font: bold, fontSize: 14)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          data: [
            for (final e in data.summary) [e.key, e.value],
          ],
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
          },
        ),
        for (final table in data.tables) ...[
          pw.SizedBox(height: 20),
          pw.Text(table.title, style: pw.TextStyle(font: bold, fontSize: 14)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: table.headers,
            data: table.rows,
            headerStyle: pw.TextStyle(font: bold, fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: tableHeaderColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
          ),
        ],
        pw.SizedBox(height: 16),
        pw.Text(
          '※ 本レポートは受講記録と自己申告のチェック状況の集計であり、法令への適合を保証するものではありません。',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    ),
  );
  return doc.save();
}

/// 表ごとのCSV(BOM付きUTF-8でExcelでも文字化けしない)。[tableIndex]の表を出力する。
Uint8List buildReportCsv(ReportData data, {int tableIndex = 0}) {
  final table = data.tables[tableIndex];
  final content = const ListToCsvConverter().convert([
    table.headers,
    ...table.rows,
  ]);
  return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(content)]);
}
