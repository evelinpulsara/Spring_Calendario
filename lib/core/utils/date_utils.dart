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
