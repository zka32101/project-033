import 'company_profile.dart';
import 'firestore_date_parser.dart';

enum PlanType { individual, team, trial }

/// 有料契約の課金元。none=未契約(お試し中を含む)、store=ストア課金、invoice=請求書払い(Web決済)。
/// 契約状態の反映はサーバー側(Cloud Functions)で行う想定で、クライアントは読み取り専用。
enum BillingSource { none, store, invoice }

class Company {
  final String id;
  final String name;
  final String industryId;
  final PlanType planType;
  final int contractedHeadcount;
  final Map<String, int> customPassThreshold; // moduleId -> pass %
  final Map<String, DateTime> moduleDeadlines; // moduleId -> 受講期限
  final String contactEmail; // 月次レポート等の送付先(空文字なら未設定)
  final Map<String, int> categoryPriorityOverride; // CategoryId.name -> 優先度(0/1/2)
  final DateTime createdAt;
  final BillingSource billingSource;
  final CompanyProfile? profile; // 規模・事業の特徴(未入力ならnull)
  /// 管理者が受講対象(必須)に指定した研修ID。未設定(null)なら業種の重点分野で必須/任意を決める。
  final List<String>? assignedModuleIds;
  /// 職種(JobRole.id)ごとに、追加で必須とする研修ID。
  final Map<String, List<String>> roleAssignments;
  final DateTime? trialEndsAt; // お試し(14日・5名)の終了日時。お試しでなければnull

  const Company({
    required this.id,
    required this.name,
    required this.industryId,
    required this.planType,
    required this.contractedHeadcount,
    required this.customPassThreshold,
    this.moduleDeadlines = const {},
    this.contactEmail = '',
    this.categoryPriorityOverride = const {},
    required this.createdAt,
    this.billingSource = BillingSource.none,
    this.profile,
    this.assignedModuleIds,
    this.roleAssignments = const {},
    this.trialEndsAt,
  });

  bool get isTrial => planType == PlanType.trial;

  /// 法令の適用基準になる従業員数。会社情報が未入力なら契約人数で代用する。
  int get legalEmployeeCount => profile?.employeeCount ?? contractedHeadcount;

  /// お試し期間中か(期限前)。期間中は全モジュールを開放する。
  bool isTrialActive([DateTime? now]) =>
      isTrial && trialEndsAt != null && (now ?? DateTime.now()).isBefore(trialEndsAt!);

  /// 残り日数(切り上げ)。お試しでない/期限切れは0。
  int trialDaysLeft([DateTime? now]) {
    if (!isTrialActive(now)) return 0;
    final left = trialEndsAt!.difference(now ?? DateTime.now());
    return (left.inHours / 24).ceil();
  }

  /// 企業規模による推奨合格ライン（設計書 Step3 データモデル参照）
  int recommendedPassThreshold() {
    if (legalEmployeeCount <= 20) return 70;
    if (legalEmployeeCount <= 100) return 80;
    return 90;
  }

  int passThresholdFor(String moduleId, {required int moduleDefault}) {
    return customPassThreshold[moduleId] ?? moduleDefault;
  }

  DateTime? deadlineFor(String moduleId) => moduleDeadlines[moduleId];

  factory Company.fromMap(String id, Map<String, dynamic> map) {
    return Company(
      id: id,
      name: map['name'] as String? ?? '',
      industryId: map['industryId'] as String? ?? '',
      planType: switch (map['planType'] as String?) {
        'team' => PlanType.team,
        'trial' => PlanType.trial,
        _ => PlanType.individual,
      },
      contractedHeadcount: (map['contractedHeadcount'] as num?)?.toInt() ?? 1,
      customPassThreshold: Map<String, int>.from(
        (map['customPassThreshold'] as Map?)?.map(
              (key, value) => MapEntry(key as String, (value as num).toInt()),
            ) ??
            {},
      ),
      moduleDeadlines: (map['moduleDeadlines'] as Map?)?.map(
            (key, value) => MapEntry(key as String, parseFirestoreDateTime(value)),
          ) ??
          {},
      contactEmail: map['contactEmail'] as String? ?? '',
      categoryPriorityOverride: Map<String, int>.from(
        (map['categoryPriorityOverride'] as Map?)?.map(
              (key, value) => MapEntry(key as String, (value as num).toInt()),
            ) ??
            {},
      ),
      createdAt: parseFirestoreDateTime(map['createdAt']),
      billingSource: switch (map['billingSource'] as String?) {
        'store' => BillingSource.store,
        'invoice' => BillingSource.invoice,
        _ => BillingSource.none,
      },
      profile: map['profile'] is Map
          ? CompanyProfile.fromMap(Map<String, dynamic>.from(map['profile'] as Map))
          : null,
      assignedModuleIds: map['assignedModuleIds'] is List
          ? List<String>.from(map['assignedModuleIds'] as List)
          : null,
      roleAssignments: map['roleAssignments'] is Map
          ? {
              for (final e in (map['roleAssignments'] as Map).entries)
                e.key as String: List<String>.from((e.value as List?) ?? const []),
            }
          : const {},
      trialEndsAt: parseFirestoreDateTimeOrNull(map['trialEndsAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'industryId': industryId,
        'planType': planType.name,
        'contractedHeadcount': contractedHeadcount,
        'customPassThreshold': customPassThreshold,
        'moduleDeadlines': moduleDeadlines,
        'contactEmail': contactEmail,
        'categoryPriorityOverride': categoryPriorityOverride,
        'createdAt': createdAt,
        if (trialEndsAt != null) 'trialEndsAt': trialEndsAt,
        if (profile != null) 'profile': profile!.toMap(),
        if (assignedModuleIds != null) 'assignedModuleIds': assignedModuleIds,
        if (roleAssignments.isNotEmpty) 'roleAssignments': roleAssignments,
      };

  Company copyWith({
    String? name,
    String? industryId,
    PlanType? planType,
    int? contractedHeadcount,
    Map<String, int>? customPassThreshold,
    Map<String, DateTime>? moduleDeadlines,
    String? contactEmail,
    Map<String, int>? categoryPriorityOverride,
    CompanyProfile? profile,
    List<String>? assignedModuleIds,
    Map<String, List<String>>? roleAssignments,
  }) {
    return Company(
      id: id,
      name: name ?? this.name,
      industryId: industryId ?? this.industryId,
      planType: planType ?? this.planType,
      contractedHeadcount: contractedHeadcount ?? this.contractedHeadcount,
      customPassThreshold: customPassThreshold ?? this.customPassThreshold,
      moduleDeadlines: moduleDeadlines ?? this.moduleDeadlines,
      contactEmail: contactEmail ?? this.contactEmail,
      categoryPriorityOverride: categoryPriorityOverride ?? this.categoryPriorityOverride,
      createdAt: createdAt,
      billingSource: billingSource,
      profile: profile ?? this.profile,
      assignedModuleIds: assignedModuleIds ?? this.assignedModuleIds,
      roleAssignments: roleAssignments ?? this.roleAssignments,
      trialEndsAt: trialEndsAt,
    );
  }
}
