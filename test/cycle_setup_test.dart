import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/constants/app_constants.dart';
import 'package:spring_calendario/core/di/app_dependencies.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/core/theme/app_theme.dart';
import 'package:spring_calendario/features/authentication/domain/entities/user.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/cycle/presentation/screens/cycle_setup_screen.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('el cuestionario guarda las respuestas de la usuaria', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final deps = AppDependencies(useBackend: false);
    await tester.pumpWidget(const SizedBox());
    final login = deps.sessionController
        .login(email: AppConstants.demoEmail, password: AppConstants.demoPassword);
    await tester.pump(const Duration(seconds: 1));
    await login;
    await settle(tester);
    expect(deps.sessionController.user!.cycleSetupCompleted, isFalse);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionController>.value(value: deps.sessionController),
        ChangeNotifierProvider<CycleController>.value(value: deps.cycleController),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const CycleSetupScreen(isEditing: true))),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ));
    await settle(tester);
    await tester.tap(find.text('abrir'));
    await settle(tester);

    expect(find.text('¿En qué etapa estás?'), findsOneWidget);
    await tester.tap(find.text('Adulta'));
    await settle(tester);
    await tester.tap(find.text('Continuar'));
    await settle(tester);

    expect(find.text('¿Cuántos días dura tu periodo?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '6'));
    await settle(tester);
    await tester.tap(find.text('Continuar'));
    await settle(tester);

    expect(find.text('¿Cada cuántos días te llega?'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await settle(tester);

    await tester.tap(find.text('No, es irregular'));
    await settle(tester);
    await tester.tap(find.text('Continuar'));
    await settle(tester);

    expect(find.text('¿Cuándo empezó tu última menstruación?'), findsOneWidget);
    expect(find.textContaining('Seleccionado:'), findsOneWidget);
    await tester.tap(find.text('Ver mi predicción'));
    await settle(tester);

    final user = deps.sessionController.user!;
    expect(user.cycleSetupCompleted, isTrue);
    expect(user.ageGroup, AgeGroup.adult);
    expect(user.averagePeriodDuration, 6);
    expect(user.regularity, CycleRegularity.irregular);
    expect(find.text('abrir'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
