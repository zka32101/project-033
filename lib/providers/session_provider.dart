import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/employee_model.dart';
import '../data/models/company_model.dart';

/// ログイン中の受講者/管理者セッション（招待コード入力 or 個人登録後にセット）
class SessionState {
  final Employee? employee;
  final Company? company;

  const SessionState({this.employee, this.company});

  bool get isSignedIn => employee != null && company != null;
  bool get isAdmin => employee?.role == EmployeeRole.admin;

  SessionState copyWith({Employee? employee, Company? company}) {
    return SessionState(
      employee: employee ?? this.employee,
      company: company ?? this.company,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier() : super(const SessionState());

  static const _companyKey = 'session_company_id';
  static const _employeeKey = 'session_employee_id';

  /// 再起動後のセッション復元用に保存済みの (companyId, employeeId) を返す。
  static Future<({String companyId, String employeeId})?> savedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final c = prefs.getString(_companyKey);
      final e = prefs.getString(_employeeKey);
      if (c == null || e == null) return null;
      return (companyId: c, employeeId: e);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(String? companyId, String? employeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (companyId == null || employeeId == null) {
        await prefs.remove(_companyKey);
        await prefs.remove(_employeeKey);
      } else {
        await prefs.setString(_companyKey, companyId);
        await prefs.setString(_employeeKey, employeeId);
      }
    } catch (_) {
      // 保存失敗でもセッション自体は継続する。
    }
  }

  void signIn({required Employee employee, required Company company}) {
    state = SessionState(employee: employee, company: company);
    _persist(company.id, employee.id);
  }

  void signOut() {
    state = const SessionState();
    _persist(null, null);
  }

  /// 管理者設定画面などでCompanyServiceによりFirestoreへ部分更新をかけた直後、
  /// セッション上のcompanyスナップショットにも同じ変更を反映する。
  /// これを呼ばないと、次にwatchCompanyで再取得する(=サインアウト/インするまで)
  /// 画面上の表示が保存前の値のまま残ってしまう。
  void updateCompany(Company company) {
    state = state.copyWith(company: company);
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});
