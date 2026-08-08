import 'package:firebase_analytics/firebase_analytics.dart';

/// KPIイベント計測（設計書 Step4.5）。
/// aha_moment_reached / module_completed / employee_invited /
/// subscription_upgraded / quiz_answered の5イベントに固定し、命名の揺れを防ぐ。
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  AnalyticsService([FirebaseAnalytics? analytics])
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  Future<void> logAhaMomentReached({
    required String companyId,
    required String moduleId,
  }) {
    return _analytics.logEvent(
      name: 'aha_moment_reached',
      parameters: {'company_id': companyId, 'module_id': moduleId},
    );
  }

  Future<void> logModuleCompleted({
    required String companyId,
    required String moduleId,
    required int score,
  }) {
    return _analytics.logEvent(
      name: 'module_completed',
      parameters: {
        'company_id': companyId,
        'module_id': moduleId,
        'score': score,
      },
    );
  }

  Future<void> logEmployeeInvited({required String companyId}) {
    return _analytics.logEvent(
      name: 'employee_invited',
      parameters: {'company_id': companyId},
    );
  }

  Future<void> logSubscriptionUpgraded({
    required String companyId,
    required bool fullSet,
    required int moduleCount,
  }) {
    return _analytics.logEvent(
      name: 'subscription_upgraded',
      parameters: {
        'company_id': companyId,
        'full_set': fullSet,
        'module_count': moduleCount,
      },
    );
  }

  Future<void> logQuizAnswered({
    required String companyId,
    required String moduleId,
    required String questionId,
    required bool correct,
  }) {
    return _analytics.logEvent(
      name: 'quiz_answered',
      parameters: {
        'company_id': companyId,
        'module_id': moduleId,
        'question_id': questionId,
        'correct': correct,
      },
    );
  }
}
