import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:spring_calendario/core/constants/app_constants.dart';
import 'package:spring_calendario/core/di/app_dependencies.dart';
import 'package:spring_calendario/core/l10n/app_localizations.dart';
import 'package:spring_calendario/core/l10n/locale_controller.dart';
import 'package:spring_calendario/core/realtime/realtime_service.dart';
import 'package:spring_calendario/core/routes/app_routes.dart';
import 'package:spring_calendario/core/theme/app_theme.dart';
import 'package:spring_calendario/core/theme/theme_controller.dart';
import 'package:spring_calendario/features/authentication/presentation/controllers/session_controller.dart';
import 'package:spring_calendario/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:spring_calendario/features/intimacy/presentation/controllers/intimacy_controller.dart';
import 'package:spring_calendario/features/symptoms/presentation/controllers/symptom_controller.dart';
import 'package:spring_calendario/shared/widgets/responsive.dart';

/// Root widget. Exposes the controllers created by [AppDependencies] to the
/// widget tree through Provider.
class SpringApp extends StatelessWidget {
  const SpringApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionController>.value(value: dependencies.sessionController),
        ChangeNotifierProvider<CycleController>.value(value: dependencies.cycleController),
        ChangeNotifierProvider<SymptomController>.value(value: dependencies.symptomController),
        ChangeNotifierProvider<ThemeController>.value(value: dependencies.themeController),
        ChangeNotifierProvider<LocaleController>.value(value: dependencies.localeController),
        ChangeNotifierProvider<IntimacyController>.value(value: dependencies.intimacyController),
        ChangeNotifierProvider<RealtimeService>.value(value: dependencies.realtimeService),
      ],
      child: const _SpringMaterialApp(),
    );
  }
}

class _SpringMaterialApp extends StatelessWidget {
  const _SpringMaterialApp();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeController>().themeMode;
    final locale = context.watch<LocaleController>().locale;
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // En computadora: notificaciones pequeñas y encabezados de página web.
      builder: (context, child) {
        final page = child ?? const SizedBox.shrink();
        if (!Breakpoints.isWide(context)) return page;
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            snackBarTheme: theme.snackBarTheme.copyWith(width: 420),
            appBarTheme: theme.appBarTheme.copyWith(
              centerTitle: false,
              toolbarHeight: 84,
              titleSpacing: 32,
              titleTextStyle: theme.appBarTheme.titleTextStyle
                  ?.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 0.2),
            ),
          ),
          child: page,
        );
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
