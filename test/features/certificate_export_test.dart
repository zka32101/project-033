import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:safy/core/certificate_book.dart';
import 'package:safy/core/certificate_pdf.dart';
import 'package:safy/core/report_writers.dart';
import 'package:safy/data/models/company_model.dart';
import 'package:safy/data/models/completion_certificate_model.dart';
import 'package:safy/data/models/employee_model.dart';
import 'package:safy/features/admin/report_export/certificates_export_screen.dart';
import 'package:safy/providers/firebase_providers.dart';
import 'package:safy/providers/session_provider.dart';

Employee _emp(String id, String name, String team, {bool deactivated = false, EmployeeRole role = EmployeeRole.member}) =>
    Employee(
      id: id,
      companyId: 'c1',
      teamId: team,
      displayName: name,
      role: role,
      createdAt: DateTime(2026, 1, 1),
      deactivated: deactivated,
    );

CompletionCertificate _cert(String emp, String module, DateTime at, {int score = 90}) => CompletionCertificate(
      id: '$emp-$module',
      employeeId: emp,
      companyId: 'c1',
      moduleId: module,
      score: score,
      thresholdApplied: 80,
      issuedAt: at,
    );

final _now = DateTime(2026, 10, 15);
final _employees = [
  _emp('a1', '管理者', 'sales', role: EmployeeRole.admin),
  _emp('s1', '佐藤', 'sales'),
  _emp('k1', '鈴木', 'acct'),
  _emp('x1', '退職者', 'acct', deactivated: true),
];
final _titles = {'m1': 'セキュリティ基礎', 'm2': '個人情報保護'};
final _certs = [
  _cert('s1', 'm1', DateTime(2026, 10, 3)), // 今月
  _cert('k1', 'm1', DateTime(2026, 9, 20)), // 先月
  _cert('k1', 'm2', DateTime(2026, 8, 5)), // 2か月前
  _cert('x1', 'm1', DateTime(2025, 12, 1)), // 退職者・約10か月前
  _cert('gone', 'm9', DateTime(2026, 10, 10)), // 削除済みの社員・未知の研修
];

List<CertificateEntry> _entries(CertificatePeriod p, {String? team}) => CertificateBook.entries(
      certificates: _certs,
      employees: _employees,
      moduleTitles: _titles,
      period: p,
      teamId: team,
      now: _now,
    );

class _Session extends SessionNotifier {
  _Session(Employee actor) {
    state = SessionState(
      employee: actor,
      company: Company(
        id: 'c1',
        name: 'テスト株式会社',
        industryId: 'retail',
        planType: PlanType.trial,
        contractedHeadcount: 5,
        customPassThreshold: const {},
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  }
}

void main() {
  group('CertificatePeriod', () {
    test('期間の範囲(開始以上・終了未満)', () {
      expect(CertificatePeriod.all.range(_now), (from: null, to: null));
      expect(CertificatePeriod.thisMonth.range(_now), (from: DateTime(2026, 10), to: DateTime(2026, 11)));
      expect(CertificatePeriod.lastMonth.range(_now), (from: DateTime(2026, 9), to: DateTime(2026, 10)));
      expect(CertificatePeriod.last3Months.range(_now), (from: DateTime(2026, 8), to: DateTime(2026, 11)));
      expect(CertificatePeriod.last12Months.range(_now), (from: DateTime(2025, 11), to: DateTime(2026, 11)));
    });

    test('年またぎでも正しい(1月の「先月」は前年12月)', () {
      final jan = DateTime(2027, 1, 10);
      expect(CertificatePeriod.lastMonth.range(jan), (from: DateTime(2026, 12), to: DateTime(2027, 1)));
    });
  });

  group('CertificateBook.entries', () {
    test('全期間は全件(退職者・削除済みの社員も含む)で、新しい順に並ぶ', () {
      final e = _entries(CertificatePeriod.all);
      expect(e.length, 5);
      expect(e.map((x) => x.issuedAt).toList(), [
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 3),
        DateTime(2026, 9, 20),
        DateTime(2026, 8, 5),
        DateTime(2025, 12, 1),
      ]);
      expect(e.first.employeeName, '(削除済みの社員)');
      expect(e.first.moduleTitle, 'm9'); // 研修名が分からなければIDを出す
      expect(e.any((x) => x.employeeName == '退職者'), isTrue);
    });

    test('期間で絞り込める', () {
      expect(_entries(CertificatePeriod.thisMonth).length, 2);
      expect(_entries(CertificatePeriod.lastMonth).map((x) => x.employeeName), ['鈴木']);
      expect(_entries(CertificatePeriod.last3Months).length, 4);
      expect(_entries(CertificatePeriod.last12Months).length, 5);
    });

    test('チームで絞り込める(削除済みの社員はチーム指定時には含まれない)', () {
      final acct = _entries(CertificatePeriod.all, team: 'acct');
      expect(acct.map((x) => x.employeeName).toSet(), {'鈴木', '退職者'});
      expect(_entries(CertificatePeriod.all, team: 'sales').map((x) => x.employeeName), ['佐藤']);
    });
  });

  group('修了者一覧(Excel/CSV)', () {
    final entries = _entries(CertificatePeriod.all, team: 'acct');
    final report = CertificateBook.report(
      entries: entries,
      companyName: 'テスト株式会社',
      periodLabel: '全期間',
      teamLabel: '経理',
      teamNames: {'acct': '経理', 'sales': '営業'},
      now: _now,
    );

    test('サマリと表の内容が正しい', () {
      final s = {for (final e in report.summary) e.key: e.value};
      expect(s['修了証の件数'], '3件');
      expect(s['修了した社員数'], '2名');
      expect(s['対象チーム'], '経理');
      expect(report.tables.single.rows.first, ['鈴木', '経理', 'セキュリティ基礎', '2026-09-20', '90', '80']);
    });

    test('Excelで読み戻せ、CSVはBOM付きで氏名を含む', () {
      final book = Excel.decodeBytes(buildReportXlsx(report));
      expect(book.tables.keys, containsAll(['サマリ', '修了者一覧']));
      expect(book.tables['修了者一覧']!.rows.length, 4); // ヘッダ+3件
      final csv = buildReportCsv(report);
      expect(csv.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(csv.sublist(3)), contains('退職者'));
    });
  });

  group('修了証PDF', () {
    test('1件につき1ページ', () async {
      final one = await buildCertificatesPdf(
        _entries(CertificatePeriod.thisMonth).take(1).toList(),
        companyName: 'テスト株式会社',
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      );
      final five = await buildCertificatesPdf(
        _entries(CertificatePeriod.all),
        companyName: 'テスト株式会社',
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      );
      final re = RegExp(r'/Type\s*/Page(?![s\w])');
      expect(re.allMatches(latin1.decode(one, allowInvalid: true)).length, 1);
      expect(re.allMatches(latin1.decode(five, allowInvalid: true)).length, 5);
    });
  });

  group('CertificatesExportScreen', () {
    Future<FakeFirebaseFirestore> seeded() async {
      final db = FakeFirebaseFirestore();
      for (final e in _employees) {
        await db.doc('companies/c1/employees/${e.id}').set(e.toMap());
      }
      await db.doc('companies/c1/teams/sales').set({'companyId': 'c1', 'teamName': '営業', 'createdAt': DateTime(2026, 1, 1)});
      await db.doc('companies/c1/teams/acct').set({'companyId': 'c1', 'teamName': '経理', 'createdAt': DateTime(2026, 1, 1)});
      for (final c in _certs) {
        await db.doc('companies/c1/certificates/${c.id}').set(c.toMap());
      }
      await db.doc('industries/retail').set({
        'name': '小売',
        'highPriority': ['security'],
        'midPriority': <String>[],
        'lowPriority': ['privacy'],
      });
      await db.doc('modules/m1').set({'categoryId': 'security', 'title': 'セキュリティ基礎', 'description': '', 'passThresholdDefault': 80, 'isFreeTrial': false, 'sortOrder': 1});
      return db;
    }

    Widget app(FakeFirebaseFirestore db, Employee actor) => ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(db),
            sessionProvider.overrideWith((ref) => _Session(actor)),
          ],
          child: const MaterialApp(home: CertificatesExportScreen()),
        );

    testWidgets('件数が表示され、期間・チームを変えると件数が変わる', (tester) async {
      tester.view.physicalSize = const Size(900, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = await seeded();

      await tester.pumpWidget(app(db, _emp('a1', '管理者', 'sales', role: EmployeeRole.admin)));
      await tester.pumpAndSettle();
      expect(find.text('対象: 5件(4名)'), findsOneWidget);
      expect(find.text('修了証をPDFで出力(5ページ)'), findsOneWidget);

      // 期間: 今月
      await tester.tap(find.byKey(const Key('period')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('今月').last);
      await tester.pumpAndSettle();
      expect(find.text('対象: 2件(2名)'), findsOneWidget);

      // チーム: 経理(今月は0件)
      await tester.tap(find.byKey(const Key('team')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('経理').last);
      await tester.pumpAndSettle();
      expect(find.text('対象: 0件(0名)'), findsOneWidget);
      expect(find.textContaining('当てはまる修了証はありません'), findsOneWidget);
      final pdfButton = find.widgetWithText(FilledButton, '修了証をPDFで出力(0ページ)');
      expect(tester.widget<FilledButton>(pdfButton).onPressed, isNull);
    });

    testWidgets('管理者以外は使えない', (tester) async {
      final db = await seeded();
      await tester.pumpWidget(app(db, _emp('s1', '佐藤', 'sales')));
      await tester.pumpAndSettle();
      expect(find.text('管理者のみ利用できます'), findsOneWidget);
    });
  });
}
