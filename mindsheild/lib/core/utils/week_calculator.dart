class WeekCalculator {
  WeekCalculator._();

  static int currentWeekIndex(DateTime? registrationDate) {
    if (registrationDate == null || registrationDate.isAfter(DateTime.now())) {
      return 0;
    }
    final daysSinceRegistration = DateTime.now()
        .difference(registrationDate)
        .inDays;
    final weekIndex = daysSinceRegistration ~/ 7;
    return weekIndex.clamp(0, 7);
  }

  static int currentWeekNumber(DateTime? registrationDate) {
    return currentWeekIndex(registrationDate) + 1;
  }

  static int currentDayIndex(DateTime? registrationDate) {
    if (registrationDate == null || registrationDate.isAfter(DateTime.now())) {
      return 0;
    }
    final daysSinceRegistration = DateTime.now()
        .difference(registrationDate)
        .inDays;
    return daysSinceRegistration.clamp(0, 55);
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
