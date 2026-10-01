import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/editor_stamp.dart';
import '../data/models/company_model.dart';
import '../data/models/company_profile.dart';
import 'firestore_paths.dart';

class CompanyService {
  final FirebaseFirestore _db;
  CompanyService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  /// ※クライアントからは呼ばない(firestore.rulesで会社の直接作成を禁止している)。
  /// 会社の作成はCloud Functions(registerCompanyAdmin)が行う。テストの準備用。
  @visibleForTesting
  Future<Company> createCompany({
    required String name,
    required String industryId,
    required PlanType planType,
    required int contractedHeadcount,
  }) async {
    final ref = _db.collection('companies').doc();
    final company = Company(
      id: ref.id,
      name: name,
      industryId: industryId,
      planType: planType,
      contractedHeadcount: contractedHeadcount,
      customPassThreshold: const {},
      createdAt: DateTime.now(),
    );
    await ref.set(company.toMap());
    return company;
  }

  Future<Company?> getCompany(String companyId) async {
    final doc = await _db.doc(FirestorePaths.company(companyId)).get();
    if (!doc.exists) return null;
    return Company.fromMap(doc.id, doc.data()!);
  }

  Stream<Company?> watchCompany(String companyId) {
    return _db.doc(FirestorePaths.company(companyId)).snapshots().map(
          (doc) => doc.exists ? Company.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Future<void> updateModulePassThreshold({
    required String companyId,
    required String moduleId,
    required int threshold,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({...EditorStamp.fields(), 
      'customPassThreshold.$moduleId': threshold,
    });
  }

  Future<void> updateModuleDeadline({
    required String companyId,
    required String moduleId,
    required DateTime dueDate,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({...EditorStamp.fields(), 
      'moduleDeadlines.$moduleId': dueDate,
    });
  }

  Future<void> clearModuleDeadline({
    required String companyId,
    required String moduleId,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({...EditorStamp.fields(), 
      'moduleDeadlines.$moduleId': FieldValue.delete(),
    });
  }

  Future<void> updateContactEmail({
    required String companyId,
    required String contactEmail,
  }) async {
    await _db
        .doc(FirestorePaths.company(companyId))
        .update({...EditorStamp.fields(), 'contactEmail': contactEmail});
  }

  Future<void> updateCategoryPriorityOverride({
    required String companyId,
    required String categoryId,
    required int priority,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({...EditorStamp.fields(), 
      'categoryPriorityOverride.$categoryId': priority,
    });
  }

  Future<void> clearCategoryPriorityOverride({
    required String companyId,
    required String categoryId,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({...EditorStamp.fields(), 
      'categoryPriorityOverride.$categoryId': FieldValue.delete(),
    });
  }

  /// 会社の規模・事業の特徴を保存する。
  Future<void> updateProfile({
    required String companyId,
    required CompanyProfile profile,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({...EditorStamp.fields(), 'profile': profile.toMap()});
  }

  /// 管理者が受講対象(必須)に指定した研修を保存する。
  Future<void> updateAssignedModules({
    required String companyId,
    required List<String> moduleIds,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({...EditorStamp.fields(), 'assignedModuleIds': moduleIds});
  }

  /// チームに、全社共通の必須に加えて必須とする研修を保存する。
  Future<void> updateTeamAssignedModules({
    required String companyId,
    required String teamId,
    required List<String> moduleIds,
  }) async {
    await _db.doc('${FirestorePaths.teams(companyId)}/$teamId').update({...EditorStamp.fields(), 'assignedModuleIds': moduleIds});
  }
}
