import 'package:flutter/material.dart';
import 'package:spring_calendario/core/theme/app_colors.dart';

/// Builds the light and dark Material themes.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.purple,
      secondary: AppColors.softPink,
    );
    final fieldColor = isLight ? Colors.white : AppColors.darkSurface;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? AppColors.background : AppColors.night,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: isLight ? AppColors.deepPurple : Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 52),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
