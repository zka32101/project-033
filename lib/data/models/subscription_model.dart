import 'firestore_date_parser.dart';

enum SubscriptionOwnerType { individual, company }
enum SubscriptionStatus { active, expired, cancelled }

class Subscription {
  final String id;
  final SubscriptionOwnerType ownerType;
  final String ownerId; // employeeId(individual) or companyId(company)
  final List<String> subscribedModuleIds;
  final bool fullSet; // 全カテゴリセット契約か
  final int headcount; // company時のみ有効(人数割引計算用)
  final SubscriptionStatus status;
  final DateTime startedAt;
  final DateTime? expiresAt;

  const Subscription({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.subscribedModuleIds,
    required this.fullSet,
    required this.headcount,
    required this.status,
    required this.startedAt,
    this.expiresAt,
  });

  bool hasAccessToModule(String moduleId) =>
      fullSet || subscribedModuleIds.contains(moduleId);

  factory Subscription.fromMap(String id, Map<String, dynamic> map) {
    return Subscription(
      id: id,
      ownerType: (map['ownerType'] as String?) == 'company'
          ? SubscriptionOwnerType.company
          : SubscriptionOwnerType.individual,
      ownerId: map['ownerId'] as String? ?? '',
      subscribedModuleIds:
          List<String>.from((map['subscribedModuleIds'] as List?) ?? []),
      fullSet: map['fullSet'] as bool? ?? false,
      headcount: (map['headcount'] as num?)?.toInt() ?? 1,
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      startedAt: parseFirestoreDateTime(map['startedAt']),
      expiresAt: parseFirestoreDateTimeOrNull(map['expiresAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'ownerType': ownerType == SubscriptionOwnerType.company
            ? 'company'
            : 'individual',
        'ownerId': ownerId,
        'subscribedModuleIds': subscribedModuleIds,
        'fullSet': fullSet,
        'headcount': headcount,
        'status': status.name,
        'startedAt': startedAt,
        'expiresAt': expiresAt,
      };
}
