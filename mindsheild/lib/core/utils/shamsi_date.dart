/// Immutable Shamsi (Jalali / Persian) calendar date.
///
/// The backend stores and exchanges every date in the Gregorian calendar
/// (ISO-8601). This value object converts a Gregorian [DateTime] into its
/// Shamsi equivalent so the UI can present dates the way Persian users expect,
/// without ever touching what is sent to or received from the server.
///
/// Follows the Single Responsibility Principle — it is only concerned with the
/// calendar conversion itself, not with how the result is formatted or shown.
class ShamsiDate {
  /// Shamsi year (e.g. 1403).
  final int year;

  /// Shamsi month, 1-based (1 = فروردین, 12 = اسفند).
  final int month;

  /// Shamsi day of month, 1-based.
  final int day;

  const ShamsiDate({
    required this.year,
    required this.month,
    required this.day,
  });

  /// Persian month names, indexed 1-based via [month] - 1.
  static const List<String> monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  /// The Persian name of this date's month.
  String get monthName => monthNames[month - 1];

  /// Convert a Gregorian [date] to its Shamsi equivalent.
  ///
  /// Only the calendar-date part (year/month/day) is converted; the time of
  /// day is identical in both calendars and is handled by the formatter.
  factory ShamsiDate.fromGregorian(DateTime date) {
    final gy = date.year;
    final gm = date.month;
    final gd = date.day;

    // Cumulative days at the start of each Gregorian month (non-leap year).
    const gDaysInMonth = [
      0,
      31,
      59,
      90,
      120,
      151,
      181,
      212,
      243,
      273,
      304,
      334,
    ];

    final gy2 = (gm > 2) ? (gy + 1) : gy;
    var days =
        355666 +
        (365 * gy) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) +
        gd +
        gDaysInMonth[gm - 1];

    var jy = -1595 + (33 * (days ~/ 12053));
    days %= 12053;

    jy += 4 * (days ~/ 1461);
    days %= 1461;

    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    final int jm;
    final int jd;
    if (days < 186) {
      jm = 1 + (days ~/ 31);
      jd = 1 + (days % 31);
    } else {
      jm = 7 + ((days - 186) ~/ 30);
      jd = 1 + ((days - 186) % 30);
    }

    return ShamsiDate(year: jy, month: jm, day: jd);
  }
}
