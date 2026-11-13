/// Idioma actual para los textos que se generan fuera de los widgets
/// (fechas, nombres de fases y síntomas, validaciones, asistente...).
///
/// [LocaleController] lo mantiene sincronizado. El español es el idioma
/// principal de la app.
class AppLanguage {
  AppLanguage._();

  static bool isSpanish = true;

  /// Devuelve el texto en español o en inglés según el idioma elegido.
  static String tr(String es, String en) => isSpanish ? es : en;
}
