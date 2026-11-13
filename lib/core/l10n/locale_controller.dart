import 'package:flutter/material.dart';
import 'package:spring_calendario/core/l10n/app_language.dart';

/// Guarda el idioma elegido (español por defecto, o inglés).
class LocaleController extends ChangeNotifier {
  LocaleController() {
    AppLanguage.isSpanish = true;
  }

  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  bool get isSpanish => _locale.languageCode == 'es';

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    AppLanguage.isSpanish = isSpanish;
    notifyListeners();
  }

  void toggle() {
    setLocale(isSpanish ? const Locale('en') : const Locale('es'));
  }
}
