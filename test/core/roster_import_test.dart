import 'package:flutter_test/flutter_test.dart';
import 'package:safy/core/roster_import.dart';

void main() {
  const teams = {'営業部', '総務部'};

  test('CSVとタブ区切り、見出し行、職種の表示名/IDを読み取る', () {
    final r = RosterImport.parse(
      '名前,チーム,職種\n佐藤 花子, 営業部, 営業\n鈴木\t総務部\t it \n"田中",営業部,hr_ga\n\n',
      teamNames: teams,
    );
    expect(r.errors, isEmpty);
    expect(r.rows.map((e) => e.name), ['佐藤 花子', '鈴木', '田中']);
    expect(r.rows[0].jobRole, 'sales');
    expect(r.rows[1].jobRole, 'it');
    expect(r.rows[2].jobRole, 'hr_ga');
  });

  test('職種は省略でき、省略するとnull', () {
    final r = RosterImport.parse('山田,営業部', teamNames: teams);
    expect(r.errors, isEmpty);
    expect(r.rows.single.jobRole, isNull);
    expect(r.rows.single.toMap(), {'name': '山田', 'teamName': '営業部'});
  });

  test('エラーは行番号つき(見出し行は数えない)', () {
    final r = RosterImport.parse('氏名,チーム\n,営業部\n高橋,存在しない\n伊藤,営業部,社長\n中村,営業部\n中村,営業部', teamNames: teams);
    expect(r.errors, [
      '1行目: 名前がありません',
      '2行目: チーム「存在しない」が見つかりません',
      '3行目: 職種「社長」が正しくありません',
      '5行目: 「中村」さんが同じチームで重複しています',
    ]);
    expect(r.rows.map((e) => e.name), ['中村']);
  });

  test('空と上限超過は取り込まない', () {
    expect(RosterImport.parse('  \n', teamNames: teams).errors, isNotEmpty);
    final many = List.generate(201, (i) => 'n$i,営業部').join('\n');
    final r = RosterImport.parse(many, teamNames: teams);
    expect(r.rows, isEmpty);
    expect(r.errors.single, contains('200人まで'));
  });
}
