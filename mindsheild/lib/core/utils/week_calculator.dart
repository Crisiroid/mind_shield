class WeekCalculator {
  WeekCalculator._();

  /// Number of full calendar days that have elapsed since [registrationDate].
  ///
  /// Both the registration date and "now" are normalized to local midnight so
  /// that the value reflects calendar days rather than 24-hour chunks. An
  /// account created late in the evening therefore rolls over to the next day
  /// at midnight instead of ~24 hours later.
  static int _calendarDaysSince(DateTime registrationDate) {
    final reg = registrationDate.toLocal();
    final now = DateTime.now();
    final regMidnight = DateTime(reg.year, reg.month, reg.day);
    final nowMidnight = DateTime(now.year, now.month, now.day);
    final days = nowMidnight.difference(regMidnight).inDays;
    return days < 0 ? 0 : days;
  }

  static int currentWeekIndex(DateTime? registrationDate) {
    if (registrationDate == null) return 0;
    final weekIndex = _calendarDaysSince(registrationDate) ~/ 7;
    return weekIndex.clamp(0, 7);
  }

  static int currentWeekNumber(DateTime? registrationDate) {
    return currentWeekIndex(registrationDate) + 1;
  }

  static int currentDayIndex(DateTime? registrationDate) {
    if (registrationDate == null) return 0;
    return _calendarDaysSince(registrationDate).clamp(0, 55);
  }

  static int currentDayNumber(DateTime? registrationDate) {
    return currentDayIndex(registrationDate) + 1;
  }

  static double progressFraction(DateTime? registrationDate) {
    return currentDayIndex(registrationDate) / 55.0;
  }

  static double weeklyProgressFraction(DateTime? registrationDate) {
    final dayIndex = currentDayIndex(registrationDate);
    final dayInWeek = dayIndex % 7;
    return dayInWeek / 6.0;
  }

  static DateTime? parseStoredDate(String? isoString) {
    if (isoString == null) return null;
    return DateTime.tryParse(isoString);
  }
}
