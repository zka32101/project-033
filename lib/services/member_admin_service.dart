import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../core/editor_stamp.dart';
import '../data/models/employee_model.dart';
import 'firestore_paths.dart';

/// メンバー管理で「できない操作」の判定(純粋ロジック)。会社に有効な管理者が0人になる操作を防ぐ。
class MemberGuard {
  const MemberGuard._();

  static int activeAdminCount(List<Employee> members) =>
      members.where((m) => m.role == EmployeeRole.admin && !m.deactivated).length;

  /// 管理者を、メンバーに降格できるか。理由があれば返す(できるならnull)。
  static String? whyCannotDemote(List<Employee> members, Employee target) {
    if (target.role != EmployeeRole.admin || target.deactivated) return null;
    if (activeAdminCount(members) <= 1) return '管理者が1人だけのため、メンバーにできません。先に別の管理者を追加してください';
    return null;
  }

  /// メンバーを無効化(退職など)できるか。自分自身と、最後の管理者は無効化できない。
  static String? whyCannotDeactivate(List<Employee> members, Employee target, {required String actorId}) {
    if (target.id == actorId) return '自分自身は無効化できません。ほかの管理者に依頼してください';
    if (target.role == EmployeeRole.admin && !target.deactivated && activeAdminCount(members) <= 1) {
      return '管理者が1人だけのため、無効化できません';
    }
    return null;
  }
}

/// 管理者向けのメンバー管理(役割の変更・無効化・再有効化)。
/// 無効化の解除は席数の確認が必要なため、Cloud Functions(reactivateEmployee)で行う。
class MemberAdminService {
  final FirebaseFirestore _db;
  final FirebaseFunctions? _functionsOverride;

  MemberAdminService([FirebaseFirestore? db, FirebaseFunctions? functions])
      : _db = db ?? FirebaseFirestore.instance,
        _functionsOverride = functions;

  // 再有効化のときだけ必要なので、使うときに取得する(テストでFirebase初期化を不要にする)。
  FirebaseFunctions get _functions => _functionsOverride ?? FirebaseFunctions.instance;

  /// 無効化済みを含む、会社の全メンバー。
  Stream<List<Employee>> watchMembers(String companyId) {
    return _db
        .collection(FirestorePaths.employees(companyId))
        .snapshots()
        .map((snap) => snap.docs.map((d) => Employee.fromMap(d.id, d.data())).toList());
  }

  Future<void> setRole({
    required String companyId,
    required String employeeId,
    required EmployeeRole role,
  }) async {
    await _db.doc(FirestorePaths.employee(companyId, employeeId)).update({
      ...EditorStamp.fields(),
      'role': role == EmployeeRole.admin ? 'admin' : 'member',
    });
  }

  /// 管理者がメンバーの職種を設定する(職種別の必須研修の対象になる)。nullで未設定に戻す。
  Future<void> setJobRole({
    required String companyId,
    required String employeeId,
    required String? jobRoleId,
  }) async {
    await _db.doc(FirestorePaths.employee(companyId, employeeId)).update({
      ...EditorStamp.fields(),
      'jobRole': jobRoleId ?? FieldValue.delete(),
    });
  }

  Future<void> deactivate({required String companyId, required String employeeId}) async {
    await _db.doc(FirestorePaths.employee(companyId, employeeId)).update({
      ...EditorStamp.fields(),
      'deactivated': true,
      'deactivatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 無効化したメンバーを戻す。席数の上限に達している場合は、サーバーが拒否する。
  Future<void> reactivate({required String companyId, required String employeeId}) async {
    await _functions
        .httpsCallable('reactivateEmployee')
        .call({'companyId': companyId, 'employeeId': employeeId});
  }
}
