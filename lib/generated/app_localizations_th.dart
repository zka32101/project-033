// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Safy - การฝึกอบรมองค์กรที่ปลอดภัย';

  @override
  String get appSubtitle => 'แพลตฟอร์มการศึกษาองค์กรที่ขับเคลื่อนด้วย AI';

  @override
  String get appDescription =>
      'แอปพลิเคชันการศึกษาสำหรับ SME ที่เลือกเนื้อหาการฝึกอบรมที่จำเป็นโดยอัตโนมัติตามโปรไฟล์อุตสาหกรรมโดยใช้ AI';

  @override
  String get common_welcome => 'ยินดีต้อนรับ';

  @override
  String get common_hello => 'สวัสดี';

  @override
  String get common_goodbye => 'ลาก่อน';

  @override
  String get common_ok => 'ตกลง';

  @override
  String get common_cancel => 'ยกเลิก';

  @override
  String get common_save => 'บันทึก';

  @override
  String get common_delete => 'ลบ';

  @override
  String get common_edit => 'แก้ไข';

  @override
  String get common_next => 'ต่อไป';

  @override
  String get common_previous => 'ก่อนหน้า';

  @override
  String get common_submit => 'ส่ง';

  @override
  String get common_loading => 'กำลังโหลด...';

  @override
  String get common_error => 'เกิดข้อผิดพลาด';

  @override
  String get common_success => 'สำเร็จ';

  @override
  String get common_retry => 'ลองอีกครั้ง';

  @override
  String get common_noData => 'ไม่มีข้อมูล';

  @override
  String get auth_signIn => 'เข้าสู่ระบบ';

  @override
  String get auth_signUp => 'สมัครสมาชิก';

  @override
  String get auth_signOut => 'ออกจากระบบ';

  @override
  String get auth_email => 'ที่อยู่อีเมล';

  @override
  String get auth_password => 'รหัสผ่าน';

  @override
  String get auth_forgotPassword => 'ลืมรหัสผ่านหรือ';

  @override
  String get auth_rememberMe => 'จำฉันไว้';

  @override
  String get auth_invalidEmail => 'กรุณากรอกที่อยู่อีเมลที่ถูกต้อง';

  @override
  String get auth_passwordTooShort => 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';

  @override
  String get auth_passwordsDoNotMatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String get auth_signInRequired => 'Sign-in required';

  @override
  String get onboarding_welcome => 'ยินดีต้อนรับสู่ Safy';

  @override
  String get onboarding_selectIndustry => 'เลือกอุตสาหกรรมของคุณ';

  @override
  String get onboarding_selectRole => 'เลือกตำแหน่งของคุณ';

  @override
  String get onboarding_selectDepartment => 'เลือกแผนกของคุณ';

  @override
  String get onboarding_getStarted => 'เริ่มต้นใช้งาน';

  @override
  String get onboarding_skip => 'ข้าม';

  @override
  String get dashboard_home => 'หน้าแรก';

  @override
  String get dashboard_myProgress => 'ความคืบหน้าของฉัน';

  @override
  String get dashboard_reports => 'รายงาน';

  @override
  String get dashboard_settings => 'การตั้งค่า';

  @override
  String get dashboard_profile => 'โปรไฟล์';

  @override
  String get dashboard_yourProgress => 'ความคืบหน้าของคุณ';

  @override
  String get dashboard_completedCourses => 'คอร์สที่เสร็จสิ้น';

  @override
  String get dashboard_continueLearning => 'ดำเนินการเรียนรู้ต่อ';

  @override
  String get dashboard_recommendedCourses => 'คอร์สที่แนะนำ';

  @override
  String get quiz_quizzes => 'แบบทดสอบ';

  @override
  String get quiz_startQuiz => 'เริ่มแบบทดสอบ';

  @override
  String get quiz_question => 'คำถาม';

  @override
  String get quiz_of => 'จาก';

  @override
  String get quiz_selectAnswer => 'เลือกคำตอบ';

  @override
  String get quiz_submit => 'ส่งคำตอบ';

  @override
  String get quiz_skip => 'ข้าม';

  @override
  String get quiz_quizComplete => 'แบบทดสอบเสร็จสิ้น';

  @override
  String get quiz_score => 'คะแนน';

  @override
  String get quiz_correctAnswers => 'คำตอบที่ถูกต้อง';

  @override
  String get quiz_passed => 'คุณสอบผ่าน';

  @override
  String get quiz_failed => 'คุณสอบไม่ผ่าน';

  @override
  String get quiz_retake => 'ทำแบบทดสอบใหม่';

  @override
  String get quiz_explanation => 'คำอธิบาย';

  @override
  String get course_courses => 'คอร์ส';

  @override
  String get course_allCourses => 'คอร์สทั้งหมด';

  @override
  String get course_myCourses => 'คอร์สของฉัน';

  @override
  String get course_courseName => 'ชื่อคอร์ส';

  @override
  String get course_description => 'คำอธิบาย';

  @override
  String get course_duration => 'ระยะเวลา';

  @override
  String get course_startCourse => 'เริ่มคอร์ส';

  @override
  String get course_continueCourse => 'ดำเนินการคอร์สต่อ';

  @override
  String get course_completionRate => 'อัตราการเสร็จสิ้น';

  @override
  String get course_lessons => 'บทเรียน';

  @override
  String get course_certificate => 'ใบสมุด';

  @override
  String get course_downloadCertificate => 'ดาวน์โหลดใบสมุด';

  @override
  String get module_ethics => 'จริยธรรม';

  @override
  String get module_sns => 'สื่อสังคม';

  @override
  String get module_harassment => 'การ騷扰';

  @override
  String get module_security => 'ความปลอดภัย';

  @override
  String get module_phishing => 'ฟิชชิง';

  @override
  String get module_privacy => 'ความเป็นส่วนตัว';

  @override
  String get module_compliance => 'การปฏิบัติตามกฎระเบียบ';

  @override
  String get module_ai => 'ปัญญาเทียม';

  @override
  String get module_deepfake => 'ดีปเฟค';

  @override
  String get module_mental => 'สุขภาพจิต';

  @override
  String get module_bcp => 'ความต่อเนื่องของธุรกิจ';

  @override
  String get module_sustainability => 'ความยั่งยืน';

  @override
  String get module_sdgs => 'เป้าหมายการพัฒนาที่ยั่งยืน';

  @override
  String get report_reports => 'รายงาน';

  @override
  String get report_myReport => 'รายงานของฉัน';

  @override
  String get report_downloadReport => 'ดาวน์โหลดรายงาน';

  @override
  String get report_viewDetails => 'ดูรายละเอียด';

  @override
  String get report_averageScore => 'คะแนนเฉลี่ย';

  @override
  String get report_completionRate => 'อัตราการเสร็จสิ้น';

  @override
  String get report_courseProgress => 'ความคืบหน้าคอร์ส';

  @override
  String get report_timeSpent => 'เวลาที่ใช้ไป';

  @override
  String get report_lastActive => 'ใช้งานล่าสุด';

  @override
  String get report_exportCSV => 'ส่งออกเป็น CSV';

  @override
  String get report_exportPDF => 'ส่งออกเป็น PDF';

  @override
  String get settings_settings => 'การตั้งค่า';

  @override
  String get settings_language => 'ภาษา';

  @override
  String get settings_theme => 'ธีม';

  @override
  String get settings_lightMode => 'โหมดสว่าง';

  @override
  String get settings_darkMode => 'โหมดมืด';

  @override
  String get settings_systemDefault => 'ค่าเริ่มต้นของระบบ';

  @override
  String get settings_notifications => 'การแจ้งเตือน';

  @override
  String get settings_pushNotifications => 'การแจ้งเตือนแบบพุช';

  @override
  String get settings_emailNotifications => 'การแจ้งเตือนทางอีเมล';

  @override
  String get settings_weeklyDigest => 'สรุปรายสัปดาห์';

  @override
  String get settings_privacy => 'ความเป็นส่วนตัว';

  @override
  String get settings_termsOfService => 'เงื่อนไขการให้บริการ';

  @override
  String get settings_privacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get settings_about => 'เกี่ยวกับ';

  @override
  String get settings_appVersion => 'เวอร์ชันแอป';

  @override
  String get settings_checkForUpdates => 'ตรวจสอบการอัปเดต';

  @override
  String get settings_rateApp => 'จัดอันดับแอป';

  @override
  String get settings_contactSupport => 'ติดต่อการสนับสนุน';

  @override
  String get settings_deleteAccount => 'ลบบัญชี';

  @override
  String get error_networkError => 'เกิดข้อผิดพลาดในเครือข่าย';

  @override
  String get error_serverError => 'เกิดข้อผิดพลาดของเซิร์ฟเวอร์';

  @override
  String get error_timeoutError => 'หมดเวลาการร้องขอ';

  @override
  String get error_notFound => 'ไม่พบ';

  @override
  String get error_unauthorized => 'ไม่ได้รับอนุญาต';

  @override
  String get error_tryAgain => 'กรุณาลองอีกครั้ง';

  @override
  String get error_contactSupport => 'กรุณาติดต่อการสนับสนุน';

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
