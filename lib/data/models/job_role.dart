/// 受講者が選べる職種・部門。職種専用モジュール(Module.roleTags)の出し分けに使う。
class JobRole {
  final String id;
  final String label;

  const JobRole(this.id, this.label);

  static const List<JobRole> all = [
    JobRole('newcomer', '新入社員'),
    JobRole('accounting', '経理・財務'),
    JobRole('hr_ga', '人事・総務'),
    JobRole('sales', '営業'),
    JobRole('purchasing', '購買・調達'),
    JobRole('it', '情報システム'),
    JobRole('manager', '管理職'),
  ];

  static String? labelOf(String? id) {
    for (final r in all) {
      if (r.id == id) return r.label;
    }
    return null;
  }
}
