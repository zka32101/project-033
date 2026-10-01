// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Safy - 안전한 기업 교육';

  @override
  String get appSubtitle => 'AI 기반 기업 교육 플랫폼';

  @override
  String get appDescription =>
      '업종 프로필을 기반으로 AI가 필요한 교육 콘텐츠를 자동으로 선택하는 중소기업용 교육 앱';

  @override
  String get common_welcome => '환영합니다';

  @override
  String get common_hello => '안녕하세요';

  @override
  String get common_goodbye => '안녕히 가세요';

  @override
  String get common_ok => '확인';

  @override
  String get common_cancel => '취소';

  @override
  String get common_save => '저장';

  @override
  String get common_delete => '삭제';

  @override
  String get common_edit => '편집';

  @override
  String get common_next => '다음';

  @override
  String get common_previous => '이전';

  @override
  String get common_submit => '제출';

  @override
  String get common_loading => '로딩 중...';

  @override
  String get common_error => '오류가 발생했습니다';

  @override
  String get common_success => '성공';

  @override
  String get common_retry => '다시 시도';

  @override
  String get common_noData => '데이터 없음';

  @override
  String get auth_signIn => '로그인';

  @override
  String get auth_signUp => '회원가입';

  @override
  String get auth_signOut => '로그아웃';

  @override
  String get auth_email => '이메일';

  @override
  String get auth_password => '비밀번호';

  @override
  String get auth_forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get auth_rememberMe => '나를 기억하기';

  @override
  String get auth_invalidEmail => '유효한 이메일 주소를 입력하세요';

  @override
  String get auth_passwordTooShort => '비밀번호는 최소 6자 이상이어야 합니다';

  @override
  String get auth_passwordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get auth_signInRequired => 'Sign-in required';

  @override
  String get onboarding_welcome => 'Safy에 오신 것을 환영합니다';

  @override
  String get onboarding_selectIndustry => '업종 선택';

  @override
  String get onboarding_selectRole => '직무 선택';

  @override
  String get onboarding_selectDepartment => '부서 선택';

  @override
  String get onboarding_getStarted => '시작하기';

  @override
  String get onboarding_skip => '건너뛰기';

  @override
  String get dashboard_home => '홈';

  @override
  String get dashboard_myProgress => '진행 상황';

  @override
  String get dashboard_reports => '보고서';

  @override
  String get dashboard_settings => '설정';

  @override
  String get dashboard_profile => '프로필';

  @override
  String get dashboard_yourProgress => '당신의 진행 상황';

  @override
  String get dashboard_completedCourses => '완료된 과정';

  @override
  String get dashboard_continueLearning => '계속 배우기';

  @override
  String get dashboard_recommendedCourses => '추천 과정';

  @override
  String get quiz_quizzes => '퀴즈';

  @override
  String get quiz_startQuiz => '퀴즈 시작';

  @override
  String get quiz_question => '문제';

  @override
  String get quiz_of => '중';

  @override
  String get quiz_selectAnswer => '답변 선택';

  @override
  String get quiz_submit => '답변 제출';

  @override
  String get quiz_skip => '건너뛰기';

  @override
  String get quiz_quizComplete => '퀴즈 완료';

  @override
  String get quiz_score => '점수';

  @override
  String get quiz_correctAnswers => '정답';

  @override
  String get quiz_passed => '통과했습니다';

  @override
  String get quiz_failed => '실패했습니다';

  @override
  String get quiz_retake => '다시 시작하기';

  @override
  String get quiz_explanation => '설명';

  @override
  String get course_courses => '과정';

  @override
  String get course_allCourses => '모든 과정';

  @override
  String get course_myCourses => '내 과정';

  @override
  String get course_courseName => '과정명';

  @override
  String get course_description => '설명';

  @override
  String get course_duration => '기간';

  @override
  String get course_startCourse => '과정 시작';

  @override
  String get course_continueCourse => '과정 계속하기';

  @override
  String get course_completionRate => '완료율';

  @override
  String get course_lessons => '레슨';

  @override
  String get course_certificate => '인증서';

  @override
  String get course_downloadCertificate => '인증서 다운로드';

  @override
  String get module_ethics => '윤리';

  @override
  String get module_sns => '소셜 미디어';

  @override
  String get module_harassment => '괴롭힘';

  @override
  String get module_security => '보안';

  @override
  String get module_phishing => '피싱';

  @override
  String get module_privacy => '개인정보';

  @override
  String get module_compliance => '준수';

  @override
  String get module_ai => '인공지능';

  @override
  String get module_deepfake => '디ープ페이크';

  @override
  String get module_mental => '정신 건강';

  @override
  String get module_bcp => '사업 연속성';

  @override
  String get module_sustainability => '지속가능성';

  @override
  String get module_sdgs => '지속 가능한 개발 목표';

  @override
  String get report_reports => '보고서';

  @override
  String get report_myReport => '내 보고서';

  @override
  String get report_downloadReport => '보고서 다운로드';

  @override
  String get report_viewDetails => '상세 보기';

  @override
  String get report_averageScore => '평균 점수';

  @override
  String get report_completionRate => '완료율';

  @override
  String get report_courseProgress => '과정 진행률';

  @override
  String get report_timeSpent => '학습 시간';

  @override
  String get report_lastActive => '마지막 활동';

  @override
  String get report_exportCSV => 'CSV로 내보내기';

  @override
  String get report_exportPDF => 'PDF로 내보내기';

  @override
  String get settings_settings => '설정';

  @override
  String get settings_language => '언어';

  @override
  String get settings_theme => '테마';

  @override
  String get settings_lightMode => '라이트 모드';

  @override
  String get settings_darkMode => '다크 모드';

  @override
  String get settings_systemDefault => '시스템 기본값';

  @override
  String get settings_notifications => '알림';

  @override
  String get settings_pushNotifications => '푸시 알림';

  @override
  String get settings_emailNotifications => '이메일 알림';

  @override
  String get settings_weeklyDigest => '주간 요약';

  @override
  String get settings_privacy => '개인정보';

  @override
  String get settings_termsOfService => '서비스 약관';

  @override
  String get settings_privacyPolicy => '개인정보 보호정책';

  @override
  String get settings_about => '정보';

  @override
  String get settings_appVersion => '앱 버전';

  @override
  String get settings_checkForUpdates => '업데이트 확인';

  @override
  String get settings_rateApp => '앱 평가';

  @override
  String get settings_contactSupport => '지원팀 문의';

  @override
  String get settings_deleteAccount => '계정 삭제';

  @override
  String get error_networkError => '네트워크 오류가 발생했습니다';

  @override
  String get error_serverError => '서버 오류가 발생했습니다';

  @override
  String get error_timeoutError => '요청이 시간 초과되었습니다';

  @override
  String get error_notFound => '찾을 수 없습니다';

  @override
  String get error_unauthorized => '권한이 없습니다';

  @override
  String get error_tryAgain => '다시 시도하세요';

  @override
  String get error_contactSupport => '지원팀에 문의하세요';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_learningPath => 'Learning Path';

  @override
  String get nav_qaForum => 'Q&A';

  @override
  String get nav_myGrowth => 'My Growth';

  @override
  String get home_requiredTrainingTitle => 'Your Required Training';

  @override
  String get home_sessionNotFound => 'Session not found';

  @override
  String get home_adminMenuTooltip => 'Admin Menu';

  @override
  String get home_industryLoadError => 'Failed to load industry information';

  @override
  String get home_industryNotFound => 'Industry information not found';

  @override
  String get home_modulesLoadError => 'Failed to load training modules';

  @override
  String get home_noModules => 'No training modules yet';

  @override
  String get home_tier1Title => 'Tier 1 Training';

  @override
  String get home_tier1Period => 'Sep 16-22 Self-Study Period';

  @override
  String get home_tier1Description => '4 modules, 16 hours total';

  @override
  String get home_liveExamTitle => 'Live Certification Exam';

  @override
  String get home_liveExamPeriod => 'Held Oct 10-20';

  @override
  String get home_liveExamDescription => 'Take on the Tier 2/3 exams';

  @override
  String get home_monthlyRequiredModule => 'This Month\'s Required Module';

  @override
  String get home_requiredBadge => 'Required';

  @override
  String get home_optionalBadge => 'Optional';

  @override
  String get home_freeTrialBadge => 'Free Trial';

  @override
  String get home_deadlineUpcoming => 'Due Soon';

  @override
  String get home_deadlineOverdue => 'Overdue';

  @override
  String get learningPath_customTitle => 'Custom Learning Path';

  @override
  String get learningPath_loadErrorTitle => 'Failed to Load Learning Path';

  @override
  String get learningPath_levelBeginner => 'Beginner';

  @override
  String get learningPath_levelIntermediate => 'Intermediate';

  @override
  String get learningPath_levelAdvanced => 'Advanced';

  @override
  String get learningPath_recommendedModulesTitle => 'Recommended Modules';

  @override
  String get learningPath_noModules =>
      'No modules are available for this level yet';

  @override
  String learningPath_estimatedHours(int hours) {
    return 'Estimated study time: $hours hours';
  }

  @override
  String get learningPath_moduleFallbackTitle => 'Module';

  @override
  String get qaForum_title => 'Q&A Forum';

  @override
  String get qaForum_searchHint => 'Search questions...';

  @override
  String get qaForum_sortRecent => 'Recent';

  @override
  String get qaForum_sortPopular => 'Popular';

  @override
  String get qaForum_sortUnanswered => 'Unanswered';

  @override
  String get qaForum_noQuestions => 'No questions yet';

  @override
  String get qaForum_myQuestionBadge => 'Mine';

  @override
  String get qaForum_anonymousAuthor => 'Anonymous';

  @override
  String get qaForum_askQuestionTitle => 'Post a Question';

  @override
  String get qaForum_titleFieldLabel => 'Title*';

  @override
  String get qaForum_titleFieldHint => 'Enter the title of your question';

  @override
  String get qaForum_descriptionFieldLabel => 'Details';

  @override
  String get qaForum_descriptionFieldHint => 'Add more details (optional)';

  @override
  String get qaForum_categoryFieldLabel => 'Category';

  @override
  String get qaForum_categoryContent => 'Content Understanding';

  @override
  String get qaForum_categorySkillApplication => 'Skill Application';

  @override
  String get qaForum_categoryToolsSystem => 'Tools & Systems';

  @override
  String get qaForum_categoryCareer => 'Career';

  @override
  String get qaForum_categoryOther => 'Other';

  @override
  String get qaForum_postButton => 'Post';

  @override
  String get qaForum_titleRequiredError => 'Please enter a title';

  @override
  String get qaForum_postSuccess => 'Your question has been posted';

  @override
  String get qaForum_postError => 'Failed to post your question';

  @override
  String qaForum_minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String qaForum_hoursAgo(int hours) {
    return '$hours hr ago';
  }

  @override
  String qaForum_daysAgo(int days) {
    return '$days days ago';
  }
}
