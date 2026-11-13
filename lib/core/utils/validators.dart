import 'package:spring_calendario/core/l10n/app_language.dart';

/// Form validators shared by the authentication screens.
class Validators {
  Validators._();

  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) return AppLanguage.tr('$label es obligatorio', '$label is required');
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppLanguage.tr('El correo es obligatorio', 'Email is required');
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(text)
        ? null
        : AppLanguage.tr('Escribe un correo válido', 'Enter a valid email');
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppLanguage.tr('La contraseña es obligatoria', 'Password is required');
    if (value.length < 6) return AppLanguage.tr('Usa al menos 6 caracteres', 'Use at least 6 characters');
    return null;
  }
}
