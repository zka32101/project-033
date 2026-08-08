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
  EmployeeService([FirebaseFirestore? db, FirebaseAuth? auth])
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<String> _ensureAuthUid() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  Future<Employee> joinViaInviteCode({
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
      role: EmployeeRole.member,
      createdAt: DateTime.now(),
    );
    await ref.set(employee.toMap());
    return employee;
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
