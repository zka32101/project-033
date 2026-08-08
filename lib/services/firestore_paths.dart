/// Firestoreコレクションパスの単一ソース。
/// マルチテナントデータ(Company配下)とグローバルコンテンツ(業種/モジュール等)を明確に分離する。
/// 他ファイルでパス文字列を直接書かず、必ずここを経由すること。
class FirestorePaths {
  FirestorePaths._();

  // --- マルチテナント（企業単位で分離必須） ---
  static String company(String companyId) => 'companies/$companyId';
  static String teams(String companyId) => '${company(companyId)}/teams';
  static String team(String companyId, String teamId) =>
      '${teams(companyId)}/$teamId';
  static String employees(String companyId) =>
      '${company(companyId)}/employees';
  static String employee(String companyId, String employeeId) =>
      '${employees(companyId)}/$employeeId';
  static String enrollments(String companyId) =>
      '${company(companyId)}/enrollments';
  static String progressRecords(String companyId) =>
      '${company(companyId)}/progressRecords';
  static String quizAttempts(String companyId) =>
      '${company(companyId)}/quizAttempts';
  static String certificates(String companyId) =>
      '${company(companyId)}/certificates';
  static String subscriptions(String companyId) =>
      '${company(companyId)}/subscriptions';
  static String reminders(String companyId) =>
      '${company(companyId)}/reminders';

  // --- 招待コード（Join前はテナント文脈が無いためトップレベル） ---
  static const String inviteCodes = 'inviteCodes';

  // --- グローバルコンテンツ（全テナント共通・読み取り専用） ---
  static const String industries = 'industries';
  static const String modules = 'modules';
  static String lessons(String moduleId) => 'modules/$moduleId/lessons';
  static String quizQuestions(String moduleId) =>
      'modules/$moduleId/quizQuestions';
}
