import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/employee_model.dart';
import 'firestore_paths.dart';

/// EmployeeドキュメントIDは必ずFirebase AuthのuidとイコールにするEmployeeService。
/// これによりFirestoreセキュリティルールが `request.auth.uid == employeeId` の形で
/// 本人確認できるようになる(設計書Step5: 管理者/受講者の権限分離の前提)。
/// 現時点ではパスワード不要の匿名認証を用いる。実名でのログインが必要になった場合は
/// Firebase Authのメール/電話番号認証に切り替え、Employeeとの紐付け方式は変えない。
class EmployeeService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final Future<void> Function({
    required String inviteCode,
    required String displayName,
    required String companyId,
    required String teamId,
    required String uid,
  }) _joinInvoker;

  /// [joinInvoker]は招待コードでの参加を実行する処理。既定ではCloud Functions
  /// (joinCompanyViaInvite)を呼ぶ。テストではFirestoreへ直接書き込む処理を渡せる。
  EmployeeService([
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    Future<void> Function({
      required String inviteCode,
      required String displayName,
      required String companyId,
      required String teamId,
      required String uid,
    })? joinInvoker,
  ])  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _joinInvoker = joinInvoker ?? _joinViaCloudFunction;

  static Future<void> _joinViaCloudFunction({
    required String inviteCode,
    required String displayName,
    required String companyId,
    required String teamId,
    required String uid,
  }) async {
    await FirebaseFunctions.instance.httpsCallable('joinCompanyViaInvite').call({
      'inviteCode': inviteCode,
      'displayName': displayName,
    });
  }

  Future<String> ensureAuthUid() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  Future<String> _ensureAuthUid() => ensureAuthUid();

  Future<Employee> joinViaInviteCode({
    required String inviteCode,
    required String companyId,
    required String teamId,
    required String displayName,
  }) async {
    final uid = await _ensureAuthUid();
    // 参加人数の上限(お試しは5名)はサーバー側でしか数えられないためCloud Functions経由で参加する。
    await _joinInvoker(
      inviteCode: inviteCode,
      displayName: displayName,
      companyId: companyId,
      teamId: teamId,
      uid: uid,
    );
    return Employee(
      id: uid,
      companyId: companyId,
      teamId: teamId,
      displayName: displayName,
      role: EmployeeRole.member,
      createdAt: DateTime.now(),
    );
  }

  /// 受講者本人が自分の職種を設定する(null=未設定に戻す)。職種専用モジュールの出し分けに使う。
  Future<void> updateJobRole({
    required String companyId,
    required String employeeId,
    required String? jobRole,
  }) async {
    await _db.doc(FirestorePaths.employee(companyId, employeeId)).update({
      'jobRole': jobRole ?? FieldValue.delete(),
    });
  }

  Future<Employee> createAdmin({
    required String companyId,
    required String teamId,
    required String displayName,
  }) async {
    final uid = await _ensureAuthUid();
    final ref = _db.doc(FirestorePaths.employee(companyId, uid));
    final employee = Employee(
      id: uid,
      companyId: companyId,
      teamId: teamId,
      displayName: displayName,
      role: EmployeeRole.admin,
      createdAt: DateTime.now(),
    );
    await ref.set(employee.toMap());
    return employee;
  }

  Future<Employee?> getEmployee(String companyId, String employeeId) async {
    final doc =
        await _db.doc(FirestorePaths.employee(companyId, employeeId)).get();
    if (!doc.exists) return null;
    return Employee.fromMap(doc.id, doc.data()!);
  }

  Stream<List<Employee>> watchTeamEmployees(String companyId, String teamId) {
    return _db
        .collection(FirestorePaths.employees(companyId))
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Employee.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Employee>> watchCompanyEmployees(String companyId) {
    return _db
        .collection(FirestorePaths.employees(companyId))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Employee.fromMap(d.id, d.data())).toList());
  }
}
