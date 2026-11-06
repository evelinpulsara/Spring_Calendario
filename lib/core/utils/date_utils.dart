import 'package:spring_calendario/core/l10n/app_language.dart';

/// Date helpers. All cycle logic works with "date only" values (no time).
class AppDateUtils {
  AppDateUtils._();

  static const List<String> _monthsEs = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  static const List<String> _monthsShortEs = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  static const List<String> _weekdaysEs = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];
  static const List<String> _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> _monthsShortEn = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const List<String> _weekdaysEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  static List<String> get _months => AppLanguage.isSpanish ? _monthsEs : _monthsEn;
  static List<String> get _monthsShort =>
      AppLanguage.isSpanish ? _monthsShortEs : _monthsShortEn;
  static List<String> get _weekdays => AppLanguage.isSpanish ? _weekdaysEs : _weekdaysEn;

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

  static String monthYear(DateTime date) => AppLanguage.isSpanish
      ? '${_months[date.month - 1]} de ${date.year}'
      : '${_months[date.month - 1]} ${date.year}';

  /// "13 Nov" en español, "Nov 13" en inglés.
  static String shortDate(DateTime date) => AppLanguage.isSpanish
      ? '${date.day} ${_monthsShort[date.month - 1]}'
      : '${_monthsShort[date.month - 1]} ${date.day}';

  static String longDate(DateTime date) => '${_weekdays[date.weekday - 1]}, ${shortDate(date)}';

  /// Mes corto en minúscula: "oct", "nov"...
  static String monthShort(DateTime date) => _monthsShort[date.month - 1].toLowerCase();

  static String range(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return AppLanguage.isSpanish
          ? '${start.day}-${end.day} ${_monthsShort[start.month - 1]}'
          : '${_monthsShort[start.month - 1]} ${start.day}-${end.day}';
    }
    return '${shortDate(start)} - ${shortDate(end)}';
  }
}
