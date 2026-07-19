import 'shamsi_date.dart';

class PersianDateFormatter {
  PersianDateFormatter._();

  static String _pad(int value) => value.toString().padLeft(2, '0');

  static String date(DateTime date) {
    final shamsi = ShamsiDate.fromGregorian(date);
    return '${shamsi.year}/${_pad(shamsi.month)}/${_pad(shamsi.day)}';
  }

  static String dateTime(DateTime dateTime) {
    return '${date(dateTime)} - ${time(dateTime)}';
  }

  static String monthDay(DateTime date) {
    final shamsi = ShamsiDate.fromGregorian(date);
    return '${_pad(shamsi.month)}/${_pad(shamsi.day)}';
  }

  static String time(DateTime dateTime) {
    return '${_pad(dateTime.hour)}:${_pad(dateTime.minute)}';
  }
}
