import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tl.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en'),
    Locale('zh'),
    Locale('ko'),
    Locale('th'),
    Locale('vi'),
    Locale('id'),
    Locale('tl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Safy - Secure Corporate Training'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Driven Corporate Education Platform'**
  String get appSubtitle;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Educational app for SMEs that automatically selects necessary training content based on industry profiles using AI'**
  String get appDescription;

  /// No description provided for @common_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get common_welcome;

  /// No description provided for @common_hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get common_hello;

  /// No description provided for @common_goodbye.
  ///
  /// In en, this message translates to:
  /// **'Goodbye'**
  String get common_goodbye;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get common_previous;

  /// No description provided for @common_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get common_submit;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get common_noData;

  /// No description provided for @auth_signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get auth_signIn;

  /// No description provided for @auth_signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_signUp;

  /// No description provided for @auth_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get auth_signOut;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgotPassword;

  /// No description provided for @auth_rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get auth_rememberMe;

  /// No description provided for @auth_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get auth_invalidEmail;

  /// No description provided for @auth_passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get auth_passwordTooShort;

  /// No description provided for @auth_passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get auth_passwordsDoNotMatch;

  /// No description provided for @auth_signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign-in required'**
  String get auth_signInRequired;

  /// No description provided for @onboarding_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Safy'**
  String get onboarding_welcome;

  /// No description provided for @onboarding_selectIndustry.
  ///
  /// In en, this message translates to:
  /// **'Select your industry'**
  String get onboarding_selectIndustry;

  /// No description provided for @onboarding_selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get onboarding_selectRole;

  /// No description provided for @onboarding_selectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Select your department'**
  String get onboarding_selectDepartment;

  /// No description provided for @onboarding_getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_getStarted;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @dashboard_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboard_home;

  /// No description provided for @dashboard_myProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get dashboard_myProgress;

  /// No description provided for @dashboard_reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get dashboard_reports;

  /// No description provided for @dashboard_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get dashboard_settings;

  /// No description provided for @dashboard_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get dashboard_profile;

  /// No description provided for @dashboard_yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get dashboard_yourProgress;

  /// No description provided for @dashboard_completedCourses.
  ///
  /// In en, this message translates to:
  /// **'Completed Courses'**
  String get dashboard_completedCourses;

  /// No description provided for @dashboard_continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get dashboard_continueLearning;

  /// No description provided for @dashboard_recommendedCourses.
  ///
  /// In en, this message translates to:
  /// **'Recommended Courses'**
  String get dashboard_recommendedCourses;

  /// No description provided for @quiz_quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quiz_quizzes;

  /// No description provided for @quiz_startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get quiz_startQuiz;

  /// No description provided for @quiz_question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get quiz_question;

  /// No description provided for @quiz_of.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get quiz_of;

  /// No description provided for @quiz_selectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select an answer'**
  String get quiz_selectAnswer;

  /// No description provided for @quiz_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Answer'**
  String get quiz_submit;

  /// No description provided for @quiz_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get quiz_skip;

  /// No description provided for @quiz_quizComplete.
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete'**
  String get quiz_quizComplete;

  /// No description provided for @quiz_score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get quiz_score;

  /// No description provided for @quiz_correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get quiz_correctAnswers;

  /// No description provided for @quiz_passed.
  ///
  /// In en, this message translates to:
  /// **'You Passed'**
  String get quiz_passed;

  /// No description provided for @quiz_failed.
  ///
  /// In en, this message translates to:
  /// **'You Failed'**
  String get quiz_failed;

  /// No description provided for @quiz_retake.
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get quiz_retake;

  /// No description provided for @quiz_explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get quiz_explanation;

  /// No description provided for @course_courses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get course_courses;

  /// No description provided for @course_allCourses.
  ///
  /// In en, this message translates to:
  /// **'All Courses'**
  String get course_allCourses;

  /// No description provided for @course_myCourses.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get course_myCourses;

  /// No description provided for @course_courseName.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get course_courseName;

  /// No description provided for @course_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get course_description;

  /// No description provided for @course_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get course_duration;

  /// No description provided for @course_startCourse.
  ///
  /// In en, this message translates to:
  /// **'Start Course'**
  String get course_startCourse;

  /// No description provided for @course_continueCourse.
  ///
  /// In en, this message translates to:
  /// **'Continue Course'**
  String get course_continueCourse;

  /// No description provided for @course_completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get course_completionRate;

  /// No description provided for @course_lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get course_lessons;

  /// No description provided for @course_certificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get course_certificate;

  /// No description provided for @course_downloadCertificate.
  ///
  /// In en, this message translates to:
  /// **'Download Certificate'**
  String get course_downloadCertificate;

  /// No description provided for @module_ethics.
  ///
  /// In en, this message translates to:
  /// **'Ethics'**
  String get module_ethics;

  /// No description provided for @module_sns.
  ///
  /// In en, this message translates to:
  /// **'Social Media'**
  String get module_sns;

  /// No description provided for @module_harassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get module_harassment;

  /// No description provided for @module_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get module_security;

  /// No description provided for @module_phishing.
  ///
  /// In en, this message translates to:
  /// **'Phishing'**
  String get module_phishing;

  /// No description provided for @module_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get module_privacy;

  /// No description provided for @module_compliance.
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get module_compliance;

  /// No description provided for @module_ai.
  ///
  /// In en, this message translates to:
  /// **'Artificial Intelligence'**
  String get module_ai;

  /// No description provided for @module_deepfake.
  ///
  /// In en, this message translates to:
  /// **'Deepfake'**
  String get module_deepfake;

  /// No description provided for @module_mental.
  ///
  /// In en, this message translates to:
  /// **'Mental Health'**
  String get module_mental;

  /// No description provided for @module_bcp.
  ///
  /// In en, this message translates to:
  /// **'Business Continuity'**
  String get module_bcp;

  /// No description provided for @module_sustainability.
  ///
  /// In en, this message translates to:
  /// **'Sustainability'**
  String get module_sustainability;

  /// No description provided for @module_sdgs.
  ///
  /// In en, this message translates to:
  /// **'SDGs'**
  String get module_sdgs;

  /// No description provided for @report_reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get report_reports;

  /// No description provided for @report_myReport.
  ///
  /// In en, this message translates to:
  /// **'My Report'**
  String get report_myReport;

  /// No description provided for @report_downloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get report_downloadReport;

  /// No description provided for @report_viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get report_viewDetails;

  /// No description provided for @report_averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get report_averageScore;

  /// No description provided for @report_completionRate.
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get report_completionRate;

  /// No description provided for @report_courseProgress.
  ///
  /// In en, this message translates to:
  /// **'Course Progress'**
  String get report_courseProgress;

  /// No description provided for @report_timeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time Spent'**
  String get report_timeSpent;

  /// No description provided for @report_lastActive.
  ///
  /// In en, this message translates to:
  /// **'Last Active'**
  String get report_lastActive;

  /// No description provided for @report_exportCSV.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get report_exportCSV;

  /// No description provided for @report_exportPDF.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get report_exportPDF;

  /// No description provided for @settings_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_settings;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get settings_lightMode;

  /// No description provided for @settings_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_darkMode;

  /// No description provided for @settings_systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settings_systemDefault;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settings_pushNotifications;

  /// No description provided for @settings_emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get settings_emailNotifications;

  /// No description provided for @settings_weeklyDigest.
  ///
  /// In en, this message translates to:
  /// **'Weekly Digest'**
  String get settings_weeklyDigest;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settings_privacy;

  /// No description provided for @settings_termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_termsOfService;

  /// No description provided for @settings_privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacyPolicy;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settings_appVersion;

  /// No description provided for @settings_checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get settings_checkForUpdates;

  /// No description provided for @settings_rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get settings_rateApp;

  /// No description provided for @settings_contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settings_contactSupport;

  /// No description provided for @settings_deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settings_deleteAccount;

  /// No description provided for @error_networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get error_networkError;

  /// No description provided for @error_serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get error_serverError;

  /// No description provided for @error_timeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get error_timeoutError;

  /// No description provided for @error_notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get error_notFound;

  /// No description provided for @error_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get error_unauthorized;

  /// No description provided for @error_tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get error_tryAgain;

  /// No description provided for @error_contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Please contact support'**
  String get error_contactSupport;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_learningPath.
  ///
  /// In en, this message translates to:
  /// **'Learning Path'**
  String get nav_learningPath;

  /// No description provided for @nav_qaForum.
  ///
  /// In en, this message translates to:
  /// **'Q&A'**
  String get nav_qaForum;

  /// No description provided for @nav_myGrowth.
  ///
  /// In en, this message translates to:
  /// **'My Growth'**
  String get nav_myGrowth;

  /// No description provided for @home_requiredTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Required Training'**
  String get home_requiredTrainingTitle;

  /// No description provided for @home_sessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Session not found'**
  String get home_sessionNotFound;

  /// No description provided for @home_adminMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Admin Menu'**
  String get home_adminMenuTooltip;

  /// No description provided for @home_industryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load industry information'**
  String get home_industryLoadError;

  /// No description provided for @home_industryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Industry information not found'**
  String get home_industryNotFound;

  /// No description provided for @home_modulesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load training modules'**
  String get home_modulesLoadError;

  /// No description provided for @home_noModules.
  ///
  /// In en, this message translates to:
  /// **'No training modules yet'**
  String get home_noModules;

  /// No description provided for @home_tier1Title.
  ///
  /// In en, this message translates to:
  /// **'Tier 1 Training'**
  String get home_tier1Title;

  /// No description provided for @home_tier1Period.
  ///
  /// In en, this message translates to:
  /// **'Sep 16-22 Self-Study Period'**
  String get home_tier1Period;

  /// No description provided for @home_tier1Description.
  ///
  /// In en, this message translates to:
  /// **'4 modules, 16 hours total'**
  String get home_tier1Description;

  /// No description provided for @home_liveExamTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Certification Exam'**
  String get home_liveExamTitle;

  /// No description provided for @home_liveExamPeriod.
  ///
  /// In en, this message translates to:
  /// **'Held Oct 10-20'**
  String get home_liveExamPeriod;

  /// No description provided for @home_liveExamDescription.
  ///
  /// In en, this message translates to:
  /// **'Take on the Tier 2/3 exams'**
  String get home_liveExamDescription;

  /// No description provided for @home_monthlyRequiredModule.
  ///
  /// In en, this message translates to:
  /// **'This Month\'s Required Module'**
  String get home_monthlyRequiredModule;

  /// No description provided for @home_requiredBadge.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get home_requiredBadge;

  /// No description provided for @home_optionalBadge.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get home_optionalBadge;

  /// No description provided for @home_freeTrialBadge.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get home_freeTrialBadge;

  /// No description provided for @home_deadlineUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Due Soon'**
  String get home_deadlineUpcoming;

  /// No description provided for @home_deadlineOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get home_deadlineOverdue;

  /// No description provided for @learningPath_customTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom Learning Path'**
  String get learningPath_customTitle;

  /// No description provided for @learningPath_loadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Learning Path'**
  String get learningPath_loadErrorTitle;

  /// No description provided for @learningPath_levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get learningPath_levelBeginner;

  /// No description provided for @learningPath_levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get learningPath_levelIntermediate;

  /// No description provided for @learningPath_levelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get learningPath_levelAdvanced;

  /// No description provided for @learningPath_recommendedModulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Modules'**
  String get learningPath_recommendedModulesTitle;

  /// No description provided for @learningPath_noModules.
  ///
  /// In en, this message translates to:
  /// **'No modules are available for this level yet'**
  String get learningPath_noModules;

  /// No description provided for @learningPath_estimatedHours.
  ///
  /// In en, this message translates to:
  /// **'Estimated study time: {hours} hours'**
  String learningPath_estimatedHours(int hours);

  /// No description provided for @learningPath_moduleFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get learningPath_moduleFallbackTitle;

  /// No description provided for @qaForum_title.
  ///
  /// In en, this message translates to:
  /// **'Q&A Forum'**
  String get qaForum_title;

  /// No description provided for @qaForum_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search questions...'**
  String get qaForum_searchHint;

  /// No description provided for @qaForum_sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get qaForum_sortRecent;

  /// No description provided for @qaForum_sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get qaForum_sortPopular;

  /// No description provided for @qaForum_sortUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get qaForum_sortUnanswered;

  /// No description provided for @qaForum_noQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions yet'**
  String get qaForum_noQuestions;

  /// No description provided for @qaForum_myQuestionBadge.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get qaForum_myQuestionBadge;

  /// No description provided for @qaForum_anonymousAuthor.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get qaForum_anonymousAuthor;

  /// No description provided for @qaForum_askQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Post a Question'**
  String get qaForum_askQuestionTitle;

  /// No description provided for @qaForum_titleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title*'**
  String get qaForum_titleFieldLabel;

  /// No description provided for @qaForum_titleFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the title of your question'**
  String get qaForum_titleFieldHint;

  /// No description provided for @qaForum_descriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get qaForum_descriptionFieldLabel;

  /// No description provided for @qaForum_descriptionFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Add more details (optional)'**
  String get qaForum_descriptionFieldHint;

  /// No description provided for @qaForum_categoryFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get qaForum_categoryFieldLabel;

  /// No description provided for @qaForum_categoryContent.
  ///
  /// In en, this message translates to:
  /// **'Content Understanding'**
  String get qaForum_categoryContent;

  /// No description provided for @qaForum_categorySkillApplication.
  ///
  /// In en, this message translates to:
  /// **'Skill Application'**
  String get qaForum_categorySkillApplication;

  /// No description provided for @qaForum_categoryToolsSystem.
  ///
  /// In en, this message translates to:
  /// **'Tools & Systems'**
  String get qaForum_categoryToolsSystem;

  /// No description provided for @qaForum_categoryCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get qaForum_categoryCareer;

  /// No description provided for @qaForum_categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get qaForum_categoryOther;

  /// No description provided for @qaForum_postButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get qaForum_postButton;

  /// No description provided for @qaForum_titleRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get qaForum_titleRequiredError;

  /// No description provided for @qaForum_postSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your question has been posted'**
  String get qaForum_postSuccess;

  /// No description provided for @qaForum_postError.
  ///
  /// In en, this message translates to:
  /// **'Failed to post your question'**
  String get qaForum_postError;

  /// No description provided for @qaForum_minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min ago'**
  String qaForum_minutesAgo(int minutes);

  /// No description provided for @qaForum_hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hr ago'**
  String qaForum_hoursAgo(int hours);

  /// No description provided for @qaForum_daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String qaForum_daysAgo(int days);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'id',
    'ja',
    'ko',
    'th',
    'tl',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'th':
      return AppLocalizationsTh();
    case 'tl':
      return AppLocalizationsTl();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
