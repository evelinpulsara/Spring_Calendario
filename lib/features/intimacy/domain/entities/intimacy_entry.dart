import 'package:spring_calendario/core/l10n/app_language.dart';

/// Tipo de protección usada en una relación sexual.
enum ProtectionType { none, condom, contraceptive, unsure }

extension ProtectionTypeLabel on ProtectionType {
  String get label {
    switch (this) {
      case ProtectionType.none:
        return AppLanguage.tr('Sin protección', 'No protection');
      case ProtectionType.condom:
        return AppLanguage.tr('Con condón', 'Condom');
      case ProtectionType.contraceptive:
        return AppLanguage.tr('Con anticonceptivo', 'Birth control');
      case ProtectionType.unsure:
        return AppLanguage.tr('No estoy segura', 'Not sure');
    }
