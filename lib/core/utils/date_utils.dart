/// Date helpers. All cycle logic works with "date only" values (no time).
class AppDateUtils {
  AppDateUtils._();

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static DateTime today() => dateOnly(DateTime.now());

  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// Whole days between two dates (safe across daylight saving changes).
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String monthYear(DateTime date) => '${_months[date.month - 1]} ${date.year}';

  static String shortDate(DateTime date) => '${_monthsShort[date.month - 1]} ${date.day}';

  static String longDate(DateTime date) => '${_weekdays[date.weekday - 1]}, ${shortDate(date)}';

  static String range(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${_monthsShort[start.month - 1]} ${start.day}-${end.day}';
    }
    return '${shortDate(start)} - ${shortDate(end)}';
  }
}
