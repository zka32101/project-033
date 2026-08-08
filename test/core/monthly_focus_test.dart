import 'package:flutter_test/flutter_test.dart';
import 'package:anzet/core/monthly_focus.dart';
import 'package:anzet/data/models/module_model.dart';
import 'package:anzet/data/models/enrollment_model.dart';
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
  group('MonthlyFocus.pick', () {
    test('優先度順の先頭から未完了モジュールを選ぶ', () {
      final modules = [_module('m1'), _module('m2'), _module('m3')];
      final enrollments = [
        Enrollment(
          id: 'e1',
          employeeId: 'emp1',
          moduleId: 'm1',
          status: EnrollmentStatus.completed,
        ),
      ];

      final focus = MonthlyFocus.pick(
        priorityOrderedModules: modules,
        employeeEnrollments: enrollments,
      );

      expect(focus?.id, 'm2');
    });

    test('全て完了済みならnullを返す', () {
      final modules = [_module('m1')];
      final enrollments = [
        Enrollment(
          id: 'e1',
          employeeId: 'emp1',
          moduleId: 'm1',
          status: EnrollmentStatus.completed,
        ),
      ];

      final focus = MonthlyFocus.pick(
        priorityOrderedModules: modules,
        employeeEnrollments: enrollments,
      );

      expect(focus, isNull);
    });

    test('受講記録がなければ最優先モジュールを返す', () {
      final modules = [_module('m1'), _module('m2')];
      final focus = MonthlyFocus.pick(
        priorityOrderedModules: modules,
        employeeEnrollments: [],
      );
      expect(focus?.id, 'm1');
    });
  });
}
