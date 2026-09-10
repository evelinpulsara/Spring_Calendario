import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lunaflow/core/constants/app_constants.dart';
import 'package:lunaflow/core/di/app_dependencies.dart';
import 'package:lunaflow/core/routes/app_routes.dart';
import 'package:lunaflow/core/theme/app_theme.dart';
import 'package:lunaflow/core/theme/theme_controller.dart';
import 'package:lunaflow/features/authentication/presentation/controllers/session_controller.dart';
import 'package:lunaflow/features/cycle/presentation/controllers/cycle_controller.dart';
import 'package:lunaflow/features/symptoms/presentation/controllers/symptom_controller.dart';

/// Root widget. Exposes the controllers created by [AppDependencies] to the
/// widget tree through Provider.
class LunaFlowApp extends StatelessWidget {
  const LunaFlowApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionController>.value(value: dependencies.sessionController),
        ChangeNotifierProvider<CycleController>.value(value: dependencies.cycleController),
        ChangeNotifierProvider<SymptomController>.value(value: dependencies.symptomController),
        ChangeNotifierProvider<ThemeController>.value(value: dependencies.themeController),
      ],
      child: const _LunaFlowMaterialApp(),
    );
  }
}

class _LunaFlowMaterialApp extends StatelessWidget {
  const _LunaFlowMaterialApp();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeController>().themeMode;
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
