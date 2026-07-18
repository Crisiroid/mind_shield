import 'shamsi_date.dart';

/// Formats Gregorian [DateTime] values into user-facing Shamsi date strings.
///
/// The whole app exchanges Gregorian ISO-8601 dates with the backend, but
/// users must only ever see Shamsi dates. This is the single place that turns
/// a [DateTime] into a presentable string, so formatting stays consistent
/// everywhere.
///
/// Output uses Latin digits in a numeric, zero-padded format (e.g. 1403/01/15).
///
/// Follows the Single Responsibility Principle — conversion lives in
/// [ShamsiDate]; this class is only concerned with presentation.
class PersianDateFormatter {
  PersianDateFormatter._();

  static String _pad(int value) => value.toString().padLeft(2, '0');

  /// A Shamsi date: `1403/01/15`.
  static String date(DateTime date) {
    final shamsi = ShamsiDate.fromGregorian(date);
    return '${shamsi.year}/${_pad(shamsi.month)}/${_pad(shamsi.day)}';
  }

  /// A Shamsi date with time of day: `1403/01/15 - 14:30`.
  static String dateTime(DateTime dateTime) {
    return '${date(dateTime)} - ${time(dateTime)}';
  }

  /// A compact Shamsi month/day: `01/15`.
  static String monthDay(DateTime date) {
    final shamsi = ShamsiDate.fromGregorian(date);
    return '${_pad(shamsi.month)}/${_pad(shamsi.day)}';
  }

  /// Time of day: `14:30`. Identical in both calendars; centralized here so
  /// callers do not build time strings by hand.
  static String time(DateTime dateTime) {
    return '${_pad(dateTime.hour)}:${_pad(dateTime.minute)}';
  }
}
