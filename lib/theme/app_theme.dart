import 'package:flutter/material.dart';

/// Design tokens inspired by modern high-contrast fintech / neobank UI.
class AppTheme {
  // Brand colors
  static const Color background = Color(0xFFF4F6F8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF13151A);
  static const Color cardDark = Color(0xFF1E2129);

  // Vibrant Lime / Neon accent from the reference design
  static const Color limeAccent = Color(0xFFCCF638);
  static const Color limeAccentDark = Color(0xFFA8D91A);
  static const Color limeLight = Color(0xFFF3FED0);

  // Text colors
  static const Color textDark = Color(0xFF111418);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFF9FAFB);

  // Borders & Accents
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D323E);

  // Functional colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Elevation Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.20),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: limeAccent,
      colorScheme: const ColorScheme.light(
        primary: surfaceDark,
        secondary: limeAccent,
        surface: surfaceWhite,
        error: error,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
    );
  }
}
