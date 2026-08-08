import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/company_model.dart';
import 'firestore_paths.dart';

class CompanyService {
  final FirebaseFirestore _db;
  CompanyService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

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
    await _db.doc(FirestorePaths.company(companyId)).update({
      'customPassThreshold.$moduleId': threshold,
    });
  }

  Future<void> updateModuleDeadline({
    required String companyId,
    required String moduleId,
    required DateTime dueDate,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({
      'moduleDeadlines.$moduleId': dueDate,
    });
  }

  Future<void> clearModuleDeadline({
    required String companyId,
    required String moduleId,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({
      'moduleDeadlines.$moduleId': FieldValue.delete(),
    });
  }

  Future<void> updateContactEmail({
    required String companyId,
    required String contactEmail,
  }) async {
    await _db
        .doc(FirestorePaths.company(companyId))
        .update({'contactEmail': contactEmail});
  }

  Future<void> updateCategoryPriorityOverride({
    required String companyId,
    required String categoryId,
    required int priority,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({
      'categoryPriorityOverride.$categoryId': priority,
    });
  }

  Future<void> clearCategoryPriorityOverride({
    required String companyId,
    required String categoryId,
  }) async {
    await _db.doc(FirestorePaths.company(companyId)).update({
      'categoryPriorityOverride.$categoryId': FieldValue.delete(),
    });
  }

  Future<void> updateHeadcount({
    required String companyId,
    required int contractedHeadcount,
  }) async {
    await _db
        .doc(FirestorePaths.company(companyId))
        .update({'contractedHeadcount': contractedHeadcount});
  }
}
