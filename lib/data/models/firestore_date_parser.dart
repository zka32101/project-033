import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestoreから取得したDateTimeフィールドを解析する共通ヘルパー。
/// 実際のcloud_firestoreはDateTimeを保存すると読み出し時にTimestamp型として返す
/// (ミリ秒int/DateTimeとして返ってくることはない)。各モデルのfromMapでこれを
/// 個別に実装すると本番投入時に型キャストエラーになるため、ここに一本化する。
DateTime parseFirestoreDateTime(dynamic value, {DateTime? fallback}) {
  if (value == null) return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? parseFirestoreDateTimeOrNull(dynamic value) {
  if (value == null) return null;
  return parseFirestoreDateTime(value);
}
