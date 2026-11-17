class AppLanguage {
  AppLanguage._();

  static bool isSpanish = true;

  static String tr(String es, String en) => isSpanish ? es : en;
}
