import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:safy/core/report_data.dart';
import 'package:safy/core/report_writers.dart';
import 'package:safy/data/models/category_model.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/compliance_item.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/data/models/enrollment_model.dart';
import 'package:safy/data/models/module_model.dart';

Employee _emp(
  String id,
  String name, {
  EmployeeRole role = EmployeeRole.member,
  String? jobRole,
}) => Employee(
  id: id,
  companyId: 'c',
  teamId: 't',
  displayName: name,
  role: role,
  createdAt: DateTime(2026, 1, 1),
  jobRole: jobRole,
);

Module _mod(String id, String title) => Module(
  id: id,
  categoryId: CategoryId.security,
  title: title,
  description: '',
  passThresholdDefault: 80,
  isFreeTrial: false,
  sortOrder: 1,
);

Enrollment _enr(String emp, String mod, EnrollmentStatus st, {DateTime? at}) =>
    Enrollment(
      id: '$emp-$mod',
      employeeId: emp,
      moduleId: mod,
      status: st,
      completedAt: at,
    );

ReportData _sample() {
  final company = Company(
    id: 'c',
    name: '株式会社テスト',
    industryId: 'i',
    planType: PlanType.team,
    contractedHeadcount: 12,
    customPassThreshold: const {},
    createdAt: DateTime(2026, 1, 1),
  );
  return ReportBuilder.build(
    company: company,
    employees: [
      _emp('a', '山田', role: EmployeeRole.admin),
      _emp('b', '佐藤'),
    ],
    enrollments: [
      _enr('a', 'm1', EnrollmentStatus.completed, at: DateTime(2026, 9, 1)),
      _enr('a', 'm2', EnrollmentStatus.completed, at: DateTime(2026, 9, 20)),
      _enr('b', 'm1', EnrollmentStatus.inProgress),
      _enr('a', 'other', EnrollmentStatus.completed), // 対象外モジュールは数えない
    ],
    modules: [_mod('m1', 'セキュリティ基礎'), _mod('m2', '個人情報')],
    checklistItems: const [
      ComplianceItem(
        id: 'x1',
        category: ComplianceCategory.labor,
        description: '',
        title: '就業規則',
        law: '労基法89条',
        minHeadcount: 10,
      ),
      ComplianceItem(
        id: 'x2',
        category: ComplianceCategory.labor,
        description: '',
        title: '労働者名簿',
        law: '労基法107条',
      ),
      ComplianceItem(
        id: 'x3',
        category: ComplianceCategory.labor,
        description: '',
        title: '大規模のみ',
        law: '労安衛法',
        minHeadcount: 50,
      ),
    ],
    checklistStatuses: const {'x1': true},
    now: DateTime(2026, 10, 1),
  );
}

void main() {
  group('ReportBuilder', () {
    test('サマリの数値が受講記録から計算される', () {
      final s = {for (final e in _sample().summary) e.key: e.value};
      expect(s['対象社員数'], '2名');
      expect(s['対象モジュール数'], '2件');
      expect(s['全体の受講率'], '50%'); // 4セル中2修了(対象外モジュールは除外)
      expect(s['全モジュール修了者'], '1名');
      expect(s['未修了者'], '1名');
      expect(s['出力日'], '2026-10-01');
      expect(s['法令対応(義務項目)の実施率'], '50%(1/2項目)'); // 適用は x1,x2。x3は50名以上で対象外
    });

    test('社員別・モジュール別・チェックリストの表が正しい', () {
      final t = _sample().tables;
      expect(t[0].rows[0], [
        '山田',
        '管理者',
        '未設定',
        '2',
        '2',
        '100%',
        '2026-09-20',
      ]);
      expect(t[0].rows[1], ['佐藤', 'メンバー', '未設定', '0', '2', '0%', '']);
      expect(t[1].rows[0], ['セキュリティ基礎', '1', '1', '0', '50%']);
      expect(t[1].rows[1], ['個人情報', '1', '0', '1', '50%']);
      expect(t[2].rows[0].last, '実施済み');
      expect(t[2].rows[1].last, '未実施');
      expect(t[2].rows[2].last, '-');
      expect(t[2].rows[2][4], contains('対象外'));
    });

    test('社員もモジュールも0件でも落ちない', () {
      final data = ReportBuilder.build(
        company: Company(
          id: 'c',
          name: 'n',
          industryId: 'i',
          planType: PlanType.team,
          contractedHeadcount: 1,
          customPassThreshold: const {},
          createdAt: DateTime(2026, 1, 1),
        ),
        employees: const [],
        enrollments: const [],
        modules: const [],
        checklistItems: const [],
        checklistStatuses: const {},
        now: DateTime(2026, 10, 1),
      );
      expect({for (final e in data.summary) e.key: e.value}['全体の受講率'], '0%');
    });
  });

  group('writers', () {
    test('Excelはサマリ+3シートで、内容を読み戻せる', () {
      final bytes = buildReportXlsx(_sample());
      final book = Excel.decodeBytes(bytes);
      expect(book.tables.keys.toSet(), {
        'サマリ',
        '社員別の受講状況',
        'モジュール別の受講状況',
        '法令対応チェックリスト',
      });
      final emp = book.tables['社員別の受講状況']!;
      expect(emp.rows.first.map((c) => c?.value.toString()).first, '氏名');
      expect(emp.rows[1].map((c) => c?.value.toString()).first, '山田');
      final summary = book.tables['サマリ']!;
      expect(
        summary.rows.any((r) => r.any((c) => c?.value.toString() == '株式会社テスト')),
        isTrue,
      );
    });

    test('CSVはBOM付きUTF-8で、指定した表を出力する', () {
      final bytes = buildReportCsv(_sample());
      expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      final text = utf8.decode(bytes.sublist(3));
      final first = const LineSplitter().convert(text).first.trim();
      expect(first, '氏名,役割,職種,修了数,対象数,受講率,最終修了日');
      expect(text, contains('山田'));
    });

    test('PDFを生成できる(%PDFで始まる)', () async {
      final bytes = await buildReportPdf(
        _sample(),
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      );
      expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
      expect(bytes.length, greaterThan(500));
    });
  });
}
