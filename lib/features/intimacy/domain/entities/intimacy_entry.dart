import 'package:spring_calendario/core/l10n/app_language.dart';

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
  }

  bool get isUnprotected => this == ProtectionType.none || this == ProtectionType.unsure;
}

class IntimacyEntry {
  const IntimacyEntry({
    required this.id,
    required this.date,
    required this.protection,
  });

  final String id;
  final DateTime date;
  final ProtectionType protection;
}
