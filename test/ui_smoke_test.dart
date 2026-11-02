import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/di/app_dependencies.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/core/theme/app_theme.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/cycle/presentation/screens/calendar_screen.dart';
import 'package:spring_calendario/features/intimacy/domain/entities/intimacy_entry.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:spring_calendario/core/l10n/locale_controller.dart';
import 'package:spring_calendario/core/theme/theme_controller.dart';
import 'package:spring_calendario/core/utils/date_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spring_calendario/shared/widgets/main_shell.dart';
import 'package:spring_calendario/shared/widgets/sidebar.dart';

/// Va a una sección: por texto (barra o menú abierto) o por tooltip (menú escondido).
Future<void> goTo(WidgetTester tester, String tab) async {
  final byTooltip = find.byTooltip(tab);
  if (byTooltip.evaluate().isNotEmpty) {
    await tester.tap(byTooltip.first);
  } else {
    await tester.tap(find.text(tab).last);
  }
  await settle(tester);
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  for (final (name, size) in [
    ('celular', const Size(390, 844)),
    ('computadora', const Size(1440, 900)),
    ('computadora pequeña', const Size(1000, 760)),
