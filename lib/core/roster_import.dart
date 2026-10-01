import '../data/models/job_role.dart';

/// 名簿の取り込み1行。
class RosterRow {
  final String name;
  final String teamName;
  final String? jobRole; // JobRole.id

  const RosterRow({required this.name, required this.teamName, this.jobRole});

  Map<String, dynamic> toMap() => {'name': name, 'teamName': teamName, if (jobRole != null) 'jobRole': jobRole};
}

class RosterParseResult {
  final List<RosterRow> rows;

  /// 行番号つきのエラー。1件でもあれば登録しない。
  final List<String> errors;

  const RosterParseResult(this.rows, this.errors);
}

/// 貼り付けられた名簿(Excelからのコピー=タブ区切り、またはCSV)を読み取る。
/// 列は「名前, チーム名, 職種(任意)」。1行目が見出し(名前・氏名)なら読み飛ばす。
/// 職種は表示名(例: 営業)でもID(例: sales)でも指定できる。
class RosterImport {
  const RosterImport._();

  static const maxEntries = 200;

  static RosterParseResult parse(String text, {required Set<String> teamNames}) {
    final errors = <String>[];
    final rows = <RosterRow>[];
    final lines = text.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();
    if (lines.isNotEmpty && _isHeader(lines.first)) lines.removeAt(0);
    if (lines.isEmpty) return const RosterParseResult([], ['取り込む行がありません']);
    if (lines.length > maxEntries) {
      return RosterParseResult(const [], ['一度に取り込めるのは$maxEntries人までです(${lines.length}行)']);
    }
    final seen = <String>{};
    for (var i = 0; i < lines.length; i++) {
      final n = i + 1;
      final cells = _split(lines[i]);
      final name = cells.isNotEmpty ? cells[0] : '';
      final team = cells.length > 1 ? cells[1] : '';
      final roleText = cells.length > 2 ? cells[2] : '';
      if (name.isEmpty) {
        errors.add('$n行目: 名前がありません');
        continue;
      }
      if (!teamNames.contains(team)) {
        errors.add('$n行目: チーム「$team」が見つかりません');
        continue;
      }
      String? role;
      if (roleText.isNotEmpty) {
        role = _roleId(roleText);
        if (role == null) {
          errors.add('$n行目: 職種「$roleText」が正しくありません');
          continue;
        }
      }
      if (!seen.add('$team\u0000$name')) {
        errors.add('$n行目: 「$name」さんが同じチームで重複しています');
        continue;
      }
      rows.add(RosterRow(name: name, teamName: team, jobRole: role));
    }
    return RosterParseResult(rows, errors);
  }

  static bool _isHeader(String line) {
    final first = _split(line).first;
    return first == '名前' || first == '氏名';
  }

  static List<String> _split(String line) {
    final sep = line.contains('\t') ? '\t' : (line.contains(',') ? ',' : '、');
    return line.split(sep).map((c) => c.trim().replaceAll('"', '')).toList();
  }

  static String? _roleId(String text) {
    for (final r in JobRole.all) {
      if (r.id == text || r.label == text) return r.id;
    }
    return null;
  }
}
