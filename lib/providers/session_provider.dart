import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  void signIn({required Employee employee, required Company company}) {
    state = SessionState(employee: employee, company: company);
  }

  void signOut() {
    state = const SessionState();
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier();
});
