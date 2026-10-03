import 'package:flutter/material.dart';

/// LunaFlow palette: lavender and purple with soft pink accents.
class AppColors {
  AppColors._();

  static const Color deepPurple = Color(0xFF5B3FA0);
  static const Color purple = Color(0xFF8E6BE8);
  static const Color lavender = Color(0xFFE9E3FF);
  static const Color lavenderSoft = Color(0xFFF4F0FF);
  static const Color softPink = Color(0xFFF7B8D6);
  static const Color deepPink = Color(0xFFE87AAE);
  static const Color background = Color(0xFFFAF8FF);
  static const Color textMuted = Color(0xFF7A7192);
  static const Color moonLight = Color(0xFFFFF7E8);
  static const Color moonShadow = Color(0xFF3B2F63);
  static const Color night = Color(0xFF241C3D);
  static const Color darkSurface = Color(0xFF3A2F5C);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B7BF0), Color(0xFF5B3FA0)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFB79CFF), Color(0xFF5B3FA0), Color(0xFF241C3D)],
  );
}
