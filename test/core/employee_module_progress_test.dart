import 'package:flutter_test/flutter_test.dart';
import 'package:anzet/core/employee_module_progress.dart';
import 'package:anzet/data/models/module_model.dart';
import 'package:anzet/data/models/enrollment_model.dart';
import 'package:anzet/data/models/quiz_attempt_model.dart';
import 'package:anzet/data/models/category_model.dart';

Module _module(String id) {
  return Module(
    id: id,
    categoryId: CategoryId.security,
    title: id,
    description: '',
    passThresholdDefault: 80,
    isFreeTrial: false,
    sortOrder: 0,
  );
}

void main() {
  group('EmployeeModuleProgressBuilder.build', () {
    test('未受講モジュールはnotStarted・スコアnullになる', () {
      final result = EmployeeModuleProgressBuilder.build(
        modules: [_module('m1')],
        enrollments: [],
        attempts: [],
      );
      expect(result.single.status, EnrollmentStatus.notStarted);
      expect(result.single.latestScore, isNull);
      expect(result.single.attemptCount, 0);
    });

    test('受講中モジュールはinProgressになる', () {
      final result = EmployeeModuleProgressBuilder.build(
        modules: [_module('m1')],
        enrollments: [
          Enrollment(
            id: 'e1',
            employeeId: 'emp1',
            moduleId: 'm1',
            status: EnrollmentStatus.inProgress,
          ),
        ],
        attempts: [],
      );
      expect(result.single.status, EnrollmentStatus.inProgress);
    });

    test('複数回受験した場合は最新の受験結果を採用する', () {
      final result = EmployeeModuleProgressBuilder.build(
        modules: [_module('m1')],
        enrollments: [
          Enrollment(
            id: 'e1',
            employeeId: 'emp1',
            moduleId: 'm1',
            status: EnrollmentStatus.completed,
          ),
        ],
        attempts: [
          QuizAttempt(
            id: 'a1',
            employeeId: 'emp1',
            moduleId: 'm1',
            score: 60,
            passed: false,
            thresholdApplied: 80,
            selectedAnswers: const [],
            answeredAt: DateTime(2026, 1, 1),
          ),
          QuizAttempt(
            id: 'a2',
            employeeId: 'emp1',
            moduleId: 'm1',
            score: 90,
            passed: true,
            thresholdApplied: 80,
            selectedAnswers: const [],
            answeredAt: DateTime(2026, 1, 5),
          ),
        ],
      );
      expect(result.single.latestScore, 90);
      expect(result.single.latestPassed, isTrue);
      expect(result.single.attemptCount, 2);
    });

    test('他モジュールの受験記録は混ざらない', () {
      final result = EmployeeModuleProgressBuilder.build(
        modules: [_module('m1'), _module('m2')],
        enrollments: [],
        attempts: [
          QuizAttempt(
            id: 'a1',
            employeeId: 'emp1',
            moduleId: 'm2',
            score: 100,
            passed: true,
            thresholdApplied: 80,
            selectedAnswers: const [],
            answeredAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      final m1 = result.firstWhere((r) => r.module.id == 'm1');
      final m2 = result.firstWhere((r) => r.module.id == 'm2');
      expect(m1.latestScore, isNull);
      expect(m2.latestScore, 100);
    });
  });
}
