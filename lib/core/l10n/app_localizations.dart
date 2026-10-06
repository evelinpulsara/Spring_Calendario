import 'package:flutter/material.dart';

/// Simple in-app localizations — no external packages needed.
///
/// Usage:
///   final t = AppLocalizations.of(context);
///   Text(t.dashboard)
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en'));
  }

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en'), Locale('es')];

  // ── Strings ─────────────────────────────────────────────────────────────

  bool get _es => locale.languageCode == 'es';

  // Navigation / AppBar titles
  String get appName        => 'LunaFlow';
  String get dashboard      => _es ? 'Inicio'          : 'Dashboard';
  String get calendar       => _es ? 'Calendario'      : 'Calendar';
  String get insights       => _es ? 'Estadísticas'    : 'Insights';
  String get profile        => _es ? 'Perfil'          : 'Profile';
  String get settings       => _es ? 'Perfil y ajustes': 'Profile & settings';

  // Dashboard
  String get todayIs        => _es ? 'Hoy es'           : 'Today is';
  String get cycleDay       => _es ? 'Día del ciclo'    : 'Cycle day';
  String get nextPeriod     => _es ? 'Próxima menstruación' : 'Next period';
  String get fertileWindow  => _es ? 'Ventana fértil'   : 'Fertile window';
  String get logSymptoms    => _es ? 'Registrar síntomas': 'Log symptoms';
  String get recentSymptoms => _es ? 'Síntomas recientes': 'Recent symptoms';
  String get noSymptomsYet  => _es ? 'Sin síntomas registrados hoy.' : 'No symptoms logged today.';
  String get in_days        => _es ? 'en'               : 'in';
  String get days           => _es ? 'días'             : 'days';
  String get today          => _es ? 'hoy'              : 'today';
  String get tomorrow       => _es ? 'mañana'           : 'tomorrow';

  // Calendar
  String get periodDays     => _es ? 'Días de menstruación' : 'Period days';
  String get predicted      => _es ? 'Predicción'       : 'Predicted';
  String get fertile        => _es ? 'Fértil'           : 'Fertile';
  String get symptomsOn     => _es ? 'Síntomas del día' : 'Symptoms on this day';
  String get noSymptoms     => _es ? 'Sin síntomas ese día.' : 'No symptoms that day.';

  // Insights
  String get averageCycle   => _es ? 'Duración promedio del ciclo' : 'Average cycle length';
  String get averagePeriod  => _es ? 'Duración promedio del período': 'Average period duration';
  String get cyclesLogged   => _es ? 'Ciclos registrados'  : 'Cycles logged';
  String get currentPhase   => _es ? 'Fase actual'         : 'Current phase';
  String get topSymptoms    => _es ? 'Síntomas más frecuentes' : 'Top symptoms';
  String get notEnoughData  => _es ? 'Aún no hay suficientes datos.' : 'Not enough data yet.';
  String get aiInsight      => _es ? 'Sugerencia de Luna'  : 'Luna\'s insight';

  // Profile / Settings
  String get name           => _es ? 'Nombre'            : 'Name';
  String get cycleSettings  => _es ? 'Ajustes del ciclo' : 'Cycle settings';
  String get avgCycleLen    => _es ? 'Duración promedio del ciclo' : 'Average cycle length';
  String get avgPeriodDur   => _es ? 'Duración promedio del período': 'Average period duration';
  String get notifications  => _es ? 'Notificaciones'    : 'Notifications';
  String get periodReminder => _es ? 'Recordatorio de menstruación': 'Period reminders';
  String get fertileAlert   => _es ? 'Alertas de ventana fértil'  : 'Fertile window alerts';
  String get dailyReminder  => _es ? 'Recordatorio diario'        : 'Daily log reminder';
  String get notifNote      => _es
      ? 'Las preferencias se guardan, pero no se envían notificaciones reales en este prototipo.'
      : 'Preferences are saved, but no real notifications are sent in the MVP.';
  String get theme          => _es ? 'Tema'              : 'Theme';
  String get light          => _es ? 'Claro'             : 'Light';
  String get dark           => _es ? 'Oscuro'            : 'Dark';
  String get system         => _es ? 'Sistema'           : 'System';
  String get language       => _es ? 'Idioma'            : 'Language';
  String get privacy        => _es ? 'Privacidad'        : 'Privacy';
  String get privacyNote    => _es
      ? 'En este prototipo los datos se guardan solo en la memoria de la app y nunca se envían a un servidor.'
      : 'In this MVP your data is kept only in the app memory and is never sent to a server.';
  String get deleteData     => _es ? 'Eliminar todos mis datos' : 'Delete all my data';
  String get deleteConfirmTitle  => _es ? '¿Eliminar todos los datos?' : 'Delete all data?';
  String get deleteConfirmBody   => _es
      ? 'Todos los días de menstruación y síntomas serán eliminados de este dispositivo.'
      : 'All period days and symptoms will be removed from this device.';
  String get cancel         => _es ? 'Cancelar'          : 'Cancel';
  String get delete         => _es ? 'Eliminar'          : 'Delete';
  String get saveChanges    => _es ? 'Guardar cambios'   : 'Save changes';
  String get profileUpdated => _es ? 'Perfil actualizado': 'Profile updated';
  String get dataDeleted    => _es ? 'Tus datos fueron eliminados' : 'Your data was deleted';
  String get logOut         => _es ? 'Cerrar sesión'     : 'Log out';
  String get mvpNote        => _es
      ? 'Datos guardados localmente. No se envían a ningún servidor.'
      : 'Data saved locally. Not sent to any server.';

  // Log symptoms screen
  String get logSymptomsTitle => _es ? 'Registrar síntomas' : 'Log symptoms';
  String get intensity        => _es ? 'Intensidad'          : 'Intensity';
  String get addSymptom       => _es ? 'Agregar síntoma'     : 'Add symptom';
  String get symptomSaved     => _es ? 'Síntoma guardado'    : 'Symptom saved';

  // Symptom names
  String get cramps    => _es ? 'Cólicos'            : 'Cramps';
  String get headache  => _es ? 'Dolor de cabeza'    : 'Headache';
  String get mood      => _es ? 'Cambios de humor'   : 'Mood changes';
  String get bloating  => _es ? 'Hinchazón'          : 'Bloating';
  String get acne      => _es ? 'Acné'               : 'Acne';
  String get fatigue   => _es ? 'Fatiga'             : 'Fatigue';
  String get appetite  => _es ? 'Cambios de apetito' : 'Appetite changes';
  String get sleep     => _es ? 'Problemas de sueño' : 'Sleep problems';

  // Cycle phases
  String get menstrualPhase  => _es ? 'Fase menstrual'    : 'Menstrual phase';
  String get follicularPhase => _es ? 'Fase folicular'    : 'Follicular phase';
  String get ovulationPhase  => _es ? 'Fase de ovulación' : 'Ovulation phase';
  String get lutealPhase     => _es ? 'Fase lútea'        : 'Luteal phase';

  String get days_label => _es ? 'días' : 'days';
}

// ── Delegate ────────────────────────────────────────────────────────────────

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
