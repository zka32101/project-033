import 'firestore_date_parser.dart';

enum SubscriptionOwnerType { individual, company }
enum SubscriptionStatus { active, expired, cancelled }

/// オリジナルコンテンツ機能のプレミアム段階。
/// moduleCreation は moduleExtension の権限(既存モジュールへの追加)も内包する上位プラン。
enum PremiumTier { none, moduleExtension, moduleCreation }

/// モジュール受講プランの段階。利用者数(headcount)に応じた課金体系(モジュール数に
/// よらない定額)で、basicは業種プロファイルの無料体験モジュール(isFreeTrial)相当に
/// 限定される。upperはカテゴリ(分類)ごとに中項目(モジュール)単位で対象/対象外を
/// 選択でき、選んだモジュール数に関わらず料金は変わらない。
enum ModulePlanTier { basic, upper }

class Subscription {
  final String id;
  final SubscriptionOwnerType ownerType;
  final String ownerId; // employeeId(individual) or companyId(company)
  final List<String> subscribedModuleIds; // upperプランでカテゴリごとに選択したモジュール
  final bool fullSet; // upperプランで「全モジュール対象」を選んだショートカット
  final int headcount; // company時のみ有効(人数課金の基準)
  final SubscriptionStatus status;
  final ModulePlanTier planTier; // モジュール受講プランの段階(basic/upper)
  final PremiumTier premiumTier; // オリジナルコンテンツ機能の契約段階
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
    this.planTier = ModulePlanTier.basic,
    this.premiumTier = PremiumTier.none,
    required this.startedAt,
    this.expiresAt,
  });

  /// upperプランでの、無料体験を除いた個別モジュールへのアクセス可否。
  /// basicプラン(無料体験のみ)かどうかの判定はAccessControl側で行う。
  bool hasAccessToModule(String moduleId) =>
      planTier == ModulePlanTier.upper &&
      (fullSet || subscribedModuleIds.contains(moduleId));

  /// 既存モジュールへのレッスン/クイズ追加ができるか(moduleCreationは上位互換として含む)。
  bool get canExtendExistingModules =>
      premiumTier == PremiumTier.moduleExtension ||
      premiumTier == PremiumTier.moduleCreation;

  /// 新規オリジナルモジュール(レッスン+クイズ一式)を作成できるか。
  bool get canCreateOriginalModules => premiumTier == PremiumTier.moduleCreation;

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
      planTier: ModulePlanTier.values.firstWhere(
        (t) => t.name == map['planTier'],
        orElse: () => ModulePlanTier.basic,
      ),
      premiumTier: PremiumTier.values.firstWhere(
        (t) => t.name == map['premiumTier'],
        orElse: () => PremiumTier.none,
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
        'planTier': planTier.name,
        'premiumTier': premiumTier.name,
        'startedAt': startedAt,
        'expiresAt': expiresAt,
      };

  Subscription copyWith({ModulePlanTier? planTier, PremiumTier? premiumTier}) {
    return Subscription(
      id: id,
      ownerType: ownerType,
      ownerId: ownerId,
      subscribedModuleIds: subscribedModuleIds,
      fullSet: fullSet,
      headcount: headcount,
      status: status,
      planTier: planTier ?? this.planTier,
      premiumTier: premiumTier ?? this.premiumTier,
      startedAt: startedAt,
      expiresAt: expiresAt,
    );
  }
}
