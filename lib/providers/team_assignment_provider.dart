import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/team_model.dart';
import '../services/firestore_paths.dart';
import 'firebase_providers.dart';
import 'session_provider.dart';

/// 自分の所属チームに、追加で必須と指定された研修ID(全社共通の必須に加えて)。
/// チームが未所属・未指定なら空。
final myTeamExtraModulesProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final session = ref.watch(sessionProvider);
  final employee = session.employee;
  final company = session.company;
  if (employee == null || company == null || employee.teamId.isEmpty) {
    return Stream.value(const <String>[]);
  }
  return ref
      .watch(firestoreProvider)
      .doc('${FirestorePaths.teams(company.id)}/${employee.teamId}')
      .snapshots()
      .map((doc) => doc.exists ? Team.fromMap(doc.id, doc.data()!).assignedModuleIds : const <String>[]);
});
