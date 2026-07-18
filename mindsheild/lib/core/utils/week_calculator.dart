/// Utility for calculating the current week and day of the 56-day program.
///
/// All calculations are done locally from the stored registration date,
/// making the app fully functional offline. No API calls needed.
///
/// - Program duration: 56 days (8 weeks)
/// - Week indexing: 0-based internally (0 = week 1, 7 = week 8), 1-based externally
/// - Day indexing: 0-based (day 0 = first day), 1-based externally
/// - All values are capped at the program boundaries (max week 8, max day 56).
class WeekCalculator {
  WeekCalculator._();

  /// Calculate the current 0-based week index from registration date.
  ///
  /// Returns 0 for week 1, 7 for week 8+.
  /// Returns 0 if [registrationDate] is null or in the future.
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

  /// Calculate the current 1-based week number (1-8).
  static int currentWeekNumber(DateTime? registrationDate) {
    return currentWeekIndex(registrationDate) + 1;
  }

  /// Calculate the current 0-based day index (0-55).
  static int currentDayIndex(DateTime? registrationDate) {
    if (registrationDate == null || registrationDate.isAfter(DateTime.now())) {
      return 0;
    }
    final daysSinceRegistration = DateTime.now()
        .difference(registrationDate)
        .inDays;
    return daysSinceRegistration.clamp(0, 55);
  }

  /// Calculate the current 1-based day number (1-56).
  static int currentDayNumber(DateTime? registrationDate) {
    return currentDayIndex(registrationDate) + 1;
  }

  /// Overall progress percentage (0.0 - 1.0) across the full 56 days.
  static double progressFraction(DateTime? registrationDate) {
    return currentDayIndex(registrationDate) / 55.0;
  }

  /// Progress percentage within the current week (0.0 - 1.0).
  static double weeklyProgressFraction(DateTime? registrationDate) {
    final dayIndex = currentDayIndex(registrationDate);
    final dayInWeek = dayIndex % 7;
    return dayInWeek / 6.0;
  }

  /// Parse a stored ISO-8601 string back to [DateTime].
  static DateTime? parseStoredDate(String? isoString) {
    if (isoString == null) return null;
    return DateTime.tryParse(isoString);
  }
}
