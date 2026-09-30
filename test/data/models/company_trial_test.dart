import 'package:flutter_test/flutter_test.dart';
import 'package:safy/data/models/company_model.dart';

Company _company(PlanType plan, DateTime? ends) => Company(
      id: 'c',
      name: 'n',
      industryId: 'i',
      planType: plan,
      contractedHeadcount: 5,
      customPassThreshold: const {},
      createdAt: DateTime(2026, 1, 1),
      trialEndsAt: ends,
    );

void main() {
  final now = DateTime(2026, 10, 1, 12);

  test('期限前のお試しは有効で残り日数は切り上げ', () {
    final c = _company(PlanType.trial, now.add(const Duration(days: 13, hours: 1)));
    expect(c.isTrialActive(now), isTrue);
    expect(c.trialDaysLeft(now), 14);
  });

  test('期限ちょうど・期限後は無効で残り0日', () {
    expect(_company(PlanType.trial, now).isTrialActive(now), isFalse);
    final c = _company(PlanType.trial, now.subtract(const Duration(days: 1)));
    expect(c.isTrialActive(now), isFalse);
    expect(c.trialDaysLeft(now), 0);
  });

  test('お試しでない/終了日なしは無効', () {
    expect(_company(PlanType.team, now.add(const Duration(days: 5))).isTrialActive(now), isFalse);
    expect(_company(PlanType.trial, null).isTrialActive(now), isFalse);
  });

  test('fromMapでtrialEndsAtを読める', () {
    final c = Company.fromMap('c', {
      'name': 'n',
      'industryId': 'i',
      'planType': 'trial',
      'contractedHeadcount': 5,
      'trialEndsAt': now.millisecondsSinceEpoch,
      'createdAt': now.millisecondsSinceEpoch,
    });
    expect(c.isTrial, isTrue);
    expect(c.trialEndsAt, isNotNull);
  });
}
