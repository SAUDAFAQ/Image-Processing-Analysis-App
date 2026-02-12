import 'package:flutter/material.dart';

/// Exact color palette and theme from the reference ImageFlow designs.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF1E1E28);
  static const Color surface = Color(0xFF282A3A);
  static const Color surfaceElevated = Color(0xFF2F2D3D);
  static const Color card = Color(0xFF383A4F);

  // Progress / track
  static const Color progressTrack = Color(0xFF5C5C6B);

  // Accent (FAB, progress fill, primary buttons)
  static const Color accent = Color(0xFFFF6B81);
  static const Color accentDark = Color(0xFFEC407A);
  static const Color accentPdf = Color(0xFF6F385B);
  static const Color accentPdfOutline = Color(0xFFFF4081);

  // Face vs Document thumbnails
  static const Color faceThumb = Color(0xFFE91E63);
  static const Color docThumbStart = Color(0xFF7C4DFF);
  static const Color docThumbEnd = Color(0xFF448AFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF808090);

  // Splash / home hero gradient
  static const Color heroGradientTop = Color(0xFF160325);
  static const Color heroGradientBottom = Color(0xFF05010A);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: AppColors.textPrimary,
          surface: AppColors.background,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: AppColors.surface,
          onSurfaceVariant: AppColors.textSecondary,
          error: Color(0xFFCF6679),
          onError: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
      );
}
