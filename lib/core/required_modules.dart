/// 社員にとっての「必須の研修」を決める純粋ロジック。
/// 必須 = 会社全体で指定した研修 + 所属チームに追加で指定した研修。
/// 会社が受講対象を指定していない場合は、従来どおり業種の重点分野で必須/任意を決める。
class RequiredModules {
  const RequiredModules._();

  /// 受講率の分母にする研修ID。null=会社が受講対象を指定していない(全研修が対象)。
  static Set<String>? forEmployee({
    required List<String>? companyAssigned,
    List<String> teamExtra = const [],
  }) {
    if (companyAssigned == null) return null;
    return {...companyAssigned, ...teamExtra};
  }

  /// ホームで「必須」と表示するか。[categoryHigh]は業種の重点分野(指定がない場合の既定)。
  static bool isRequired({
    required String moduleId,
    required List<String>? companyAssigned,
    List<String> teamExtra = const [],
    required bool categoryHigh,
  }) {
    if (teamExtra.contains(moduleId)) return true;
    return companyAssigned != null ? companyAssigned.contains(moduleId) : categoryHigh;
  }
}
