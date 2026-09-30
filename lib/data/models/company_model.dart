import 'firestore_date_parser.dart';

enum PlanType { individual, team, trial }

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
    this.trialEndsAt,
  });

  bool get isTrial => planType == PlanType.trial;

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
    if (contractedHeadcount <= 20) return 70;
    if (contractedHeadcount <= 100) return 80;
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
      trialEndsAt: trialEndsAt,
    );
  }
}
