import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF0E7C86); // Clinical Teal
  static const Color primaryDark = Color(0xFF0A5560); // Deep Teal
  static const Color primaryTint = Color(0xFFE0F2F4); // Mist Teal

  // Neutral
  static const Color background = Color(0xFFF5F9FA); // Cool White
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color textPrimary = Color(0xFF12262B); // Ink
  static const Color textSecondary = Color(0xFF55696E); // Slate
  static const Color divider = Color(0xFFD5E2E5); // Fog

  // Status (Strictly for status only)
  static const Color success = Color(0xFF1E9E5A); // Go Green
  static const Color successTint = Color(0xFFE3F5EB);

  static const Color warning = Color(0xFFE8A317); // Caution Amber
  static const Color warningTint = Color(0xFFFFF4D9);
  static const Color warningText = Color(0xFF7A5200);

  static const Color danger = Color(0xFFD32F2F); // Alert Red
  static const Color dangerTint = Color(0xFFFDE7E7);

  static const Color info = Color(0xFF2B7BD6); // Info Blue
  static const Color infoTint = Color(0xFFE8F1FC);

  // Urgent Dark Theme (Incoming request screen)
  static const Color urgentBackground = Color(0xFF07262B);
  static const Color urgentSurface = Color(0xFF0F3A41);
  static const Color urgentText = Color(0xFFFFFFFF);
  static const Color urgentRed = Color(0xFFFF5252);
  static const Color urgentGreen = Color(0xFF2ECC71);
  static const Color urgentAmber = Color(0xFFFFC107);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontFamily: GoogleFonts.inter().fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontFamily: GoogleFonts.inter().fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TextStyle(
            fontFamily: GoogleFonts.inter().fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: GoogleFonts.inter().fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primaryTint,
        secondarySelectedColor: AppColors.primaryTint,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider),
        ),
        labelStyle: TextStyle(
          fontFamily: GoogleFonts.inter().fontFamily,
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get urgentDark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.urgentBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.urgentGreen,
        surface: AppColors.urgentSurface,
        error: AppColors.urgentRed,
      ),
      cardTheme: CardThemeData(
        color: AppColors.urgentSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.urgentSurface.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
