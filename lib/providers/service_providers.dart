import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_providers.dart';
import '../services/company_service.dart';
import '../services/invite_service.dart';
import '../services/employee_service.dart';
import '../services/content_service.dart';
import '../services/enrollment_service.dart';
import '../services/quiz_service.dart';
import '../services/subscription_service.dart';
import '../services/analytics_service.dart';
import '../services/reminder_service.dart';
import '../services/push_notification_service.dart';
import '../services/custom_content_service.dart';
import '../services/content_generation_service.dart';

final companyServiceProvider = Provider<CompanyService>((ref) {
  return CompanyService(ref.watch(firestoreProvider));
});

final inviteServiceProvider = Provider<InviteService>((ref) {
  return InviteService(ref.watch(firestoreProvider));
});

final employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService(ref.watch(firestoreProvider));
});

final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService(ref.watch(firestoreProvider));
});

final enrollmentServiceProvider = Provider<EnrollmentService>((ref) {
  return EnrollmentService(ref.watch(firestoreProvider));
});

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService(
    db: ref.watch(firestoreProvider),
    functions: ref.watch(functionsProvider),
  );
});

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(ref.watch(firestoreProvider));
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(analyticsInstanceProvider));
});

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(ref.watch(firestoreProvider));
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(db: ref.watch(firestoreProvider));
});

final customContentServiceProvider = Provider<CustomContentService>((ref) {
  return CustomContentService(ref.watch(firestoreProvider));
});

final contentGenerationServiceProvider = Provider<ContentGenerationService>((ref) {
  return ContentGenerationService(ref.watch(functionsProvider));
});
