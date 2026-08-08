/// セマンティックバージョン比較(設計書 Step6.5: 強制アップデート判定)。
/// Firestore/Firebase/UIに依存しない純粋ロジックなのでユニットテストで検証する。
class VersionCompare {
  /// [currentVersion] が [minSupportedVersion] 未満なら強制アップデートが必要。
  /// 不正な形式(数字とドット以外を含む等)の場合は安全側に倒し、強制しない(false)。
  static bool isUpdateRequired({
    required String currentVersion,
    required String minSupportedVersion,
  }) {
    final current = _parse(currentVersion);
    final minRequired = _parse(minSupportedVersion);
    if (current == null || minRequired == null) return false;

    for (var i = 0; i < 3; i++) {
      if (current[i] < minRequired[i]) return true;
      if (current[i] > minRequired[i]) return false;
    }
    return false;
  }

  static List<int>? _parse(String version) {
    final parts = version.split('.');
    if (parts.length != 3) return null;
    final numbers = <int>[];
    for (final part in parts) {
      final n = int.tryParse(part);
      if (n == null) return null;
      numbers.add(n);
    }
    return numbers;
  }
}
