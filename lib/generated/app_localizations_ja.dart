// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '安心企業研修Safy';

  @override
  String get appSubtitle => 'AI駆動の企業基礎教育プラットフォーム';

  @override
  String get appDescription => '業種プロファイルからAIが必要な教育コンテンツを自動選定する中小企業向け教育アプリ';

  @override
  String get common_welcome => 'いらっしゃいませ';

  @override
  String get common_hello => 'こんにちは';

  @override
  String get common_goodbye => 'さようなら';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'キャンセル';

  @override
  String get common_save => '保存';

  @override
  String get common_delete => '削除';

  @override
  String get common_edit => '編集';

  @override
  String get common_next => '次へ';

  @override
  String get common_previous => '前へ';

  @override
  String get common_submit => '送信';

  @override
  String get common_loading => '読み込み中...';

  @override
  String get common_error => 'エラーが発生しました';

  @override
  String get common_success => '成功しました';

  @override
  String get common_retry => '再試行';

  @override
  String get common_noData => 'データはありません';

  @override
  String get auth_signIn => 'サインイン';

  @override
  String get auth_signUp => '新規登録';

  @override
  String get auth_signOut => 'サインアウト';

  @override
  String get auth_email => 'メールアドレス';

  @override
  String get auth_password => 'パスワード';

  @override
  String get auth_forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get auth_rememberMe => 'パスワードを記憶する';

  @override
  String get auth_invalidEmail => '有効なメールアドレスを入力してください';

  @override
  String get auth_passwordTooShort => 'パスワードは6文字以上である必要があります';

  @override
  String get auth_passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get onboarding_welcome => 'Safyへようこそ';

  @override
  String get onboarding_selectIndustry => '業種を選択してください';

  @override
  String get onboarding_selectRole => '職務を選択してください';

  @override
  String get onboarding_selectDepartment => '部門を選択してください';

  @override
  String get onboarding_getStarted => '開始する';

  @override
  String get onboarding_skip => 'スキップ';

  @override
  String get dashboard_home => 'ホーム';

  @override
  String get dashboard_myProgress => '成長';

  @override
  String get dashboard_reports => 'レポート';

  @override
  String get dashboard_settings => '設定';

  @override
  String get dashboard_profile => 'プロフィール';

  @override
  String get dashboard_yourProgress => 'あなたの進捗';

  @override
  String get dashboard_completedCourses => '完了済みコース';

  @override
  String get dashboard_continueLearning => '学習を続ける';

  @override
  String get dashboard_recommendedCourses => '推奨コース';

  @override
  String get quiz_quizzes => 'クイズ';

  @override
  String get quiz_startQuiz => 'クイズを開始する';

  @override
  String get quiz_question => '問題';

  @override
  String get quiz_of => '中の';

  @override
  String get quiz_selectAnswer => '答えを選択してください';

  @override
  String get quiz_submit => '回答を送信';

  @override
  String get quiz_skip => 'スキップ';

  @override
  String get quiz_quizComplete => 'クイズ完了';

  @override
  String get quiz_score => 'スコア';

  @override
  String get quiz_correctAnswers => '正解';

  @override
  String get quiz_passed => '合格しました';

  @override
  String get quiz_failed => '不合格です';

  @override
  String get quiz_retake => 'もう一度やり直す';

  @override
  String get quiz_explanation => '解説';

  @override
  String get course_courses => 'コース';

  @override
  String get course_allCourses => 'すべてのコース';

  @override
  String get course_myCourses => 'マイコース';

  @override
  String get course_courseName => 'コース名';

  @override
  String get course_description => '説明';

  @override
  String get course_duration => '期間';

  @override
  String get course_startCourse => 'コースを開始';

  @override
  String get course_continueCourse => 'コースを続ける';

  @override
  String get course_completionRate => '完了率';

  @override
  String get course_lessons => 'レッスン';

  @override
  String get course_certificate => '修了証';

  @override
  String get course_downloadCertificate => '修了証をダウンロード';

  @override
  String get module_ethics => '倫理';

  @override
  String get module_sns => 'SNS';

  @override
  String get module_harassment => 'ハラスメント';

  @override
  String get module_security => 'セキュリティ';

  @override
  String get module_phishing => 'フィッシング';

  @override
  String get module_privacy => 'プライバシー';

  @override
  String get module_compliance => 'コンプライアンス';

  @override
  String get module_ai => 'AI';

  @override
  String get module_deepfake => 'ディープフェイク';

  @override
  String get module_mental => 'メンタルヘルス';

  @override
  String get module_bcp => 'BCP';

  @override
  String get module_sustainability => '持続可能性';

  @override
  String get module_sdgs => 'SDGs';

  @override
  String get report_reports => 'レポート';

  @override
  String get report_myReport => 'マイレポート';

  @override
  String get report_downloadReport => 'レポートをダウンロード';

  @override
  String get report_viewDetails => '詳細を表示';

  @override
  String get report_averageScore => '平均スコア';

  @override
  String get report_completionRate => '完了率';

  @override
  String get report_courseProgress => 'コース進捗';

  @override
  String get report_timeSpent => '学習時間';

  @override
  String get report_lastActive => '最終アクティビティ';

  @override
  String get report_exportCSV => 'CSVでエクスポート';

  @override
  String get report_exportPDF => 'PDFでエクスポート';

  @override
  String get settings_settings => '設定';

  @override
  String get settings_language => '言語';

  @override
  String get settings_theme => 'テーマ';

  @override
  String get settings_lightMode => 'ライトモード';

  @override
  String get settings_darkMode => 'ダークモード';

  @override
  String get settings_systemDefault => 'システムデフォルト';

  @override
  String get settings_notifications => '通知';

  @override
  String get settings_pushNotifications => 'プッシュ通知';

  @override
  String get settings_emailNotifications => 'メール通知';

  @override
  String get settings_weeklyDigest => '週間ダイジェスト';

  @override
  String get settings_privacy => 'プライバシー';

  @override
  String get settings_termsOfService => '利用規約';

  @override
  String get settings_privacyPolicy => 'プライバシーポリシー';

  @override
  String get settings_about => 'について';

  @override
  String get settings_appVersion => 'アプリバージョン';

  @override
  String get settings_checkForUpdates => 'アップデートを確認';

  @override
  String get settings_rateApp => 'アプリを評価';

  @override
  String get settings_contactSupport => 'サポートに連絡';

  @override
  String get settings_deleteAccount => 'アカウントを削除';

  @override
  String get error_networkError => 'ネットワークエラーが発生しました';

  @override
  String get error_serverError => 'サーバーエラーが発生しました';

  @override
  String get error_timeoutError => 'リクエストがタイムアウトしました';

  @override
  String get error_notFound => '見つかりません';

  @override
  String get error_unauthorized => '認可されていません';

  @override
  String get error_tryAgain => 'もう一度試してください';

  @override
  String get error_contactSupport => 'サポートに連絡してください';
}
