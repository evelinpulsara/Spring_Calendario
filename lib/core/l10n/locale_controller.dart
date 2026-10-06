import 'package:flutter/material.dart';

/// Holds the selected locale (English or Spanish).
class LocaleController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isSpanish => _locale.languageCode == 'es';

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
  }

  void toggle() {
    setLocale(isSpanish ? const Locale('en') : const Locale('es'));
  }
}
