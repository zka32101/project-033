/// モジュール受講期限の状態判定(管理者が設定した期限に基づく自動通知の判定ロジック)。
/// Firestore/UIに依存しない純粋ロジックなのでユニットテストで検証する。
enum DeadlineStatus { none, ok, upcoming, overdue }

class DeadlineStatusEvaluator {
  /// [dueDate]が未設定ならnone。完了済みなら期限に関わらずok。
  /// [reminderWindowDays]以内に迫っている場合はupcoming、過ぎていればoverdue。
  static DeadlineStatus evaluate({
    required DateTime? dueDate,
    required bool isCompleted,
    required DateTime now,
    int reminderWindowDays = 3,
  }) {
    if (dueDate == null) return DeadlineStatus.none;
    if (isCompleted) return DeadlineStatus.ok;

    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);
    final daysRemaining = dueDateOnly.difference(nowDateOnly).inDays;

    if (daysRemaining < 0) return DeadlineStatus.overdue;
    if (daysRemaining <= reminderWindowDays) return DeadlineStatus.upcoming;
    return DeadlineStatus.ok;
  }
}
