class ShamsiDate {
  final int year;

  final int month;

  final int day;

  const ShamsiDate({
    required this.year,
    required this.month,
    required this.day,
  });

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

  String get monthName => monthNames[month - 1];

  factory ShamsiDate.fromGregorian(DateTime date) {
    final gy = date.year;
    final gm = date.month;
    final gd = date.day;

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
