import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bgDark = Color(0xFFFAF3E7);
  static const Color bgCard = Color(0xFFFFFCF4);
  static const Color bgCardLight = Color(0xFFF4E7D2);
  static const Color bgCardHover = Color(0xFFFFF7E6);
  static const Color accentPurple = Color(0xFF7A4CC2);
  static const Color accentPurpleLight = Color(0xFF9B6FE0);
  static const Color accentBlue = Color(0xFF2F7BBF);
  static const Color accentCyan = Color(0xFF158C9E);
  static const Color accentGreen = Color(0xFF2E9463);
  static const Color accentRed = Color(0xFFD8463D);
  static const Color accentOrange = Color(0xFFE28B32);
  static const Color accentPink = Color(0xFFD95E8E);
  static const Color accentGold = Color(0xFFE2B03A);
  static const Color textPrimary = Color(0xFF201B18);
  static const Color textSecondary = Color(0xFF665B52);
  static const Color textMuted = Color(0xFF8A7D70);
  static const Color divider = Color(0xFFD8C8B3);
  static const Color ink = Color(0xFF201B18);
  static const Color paperLine = Color(0xFFEADBC7);
  static const Color shimmer = Color(0x22FFFFFF);
}

class AppGradients {
  static const LinearGradient purple = LinearGradient(
    colors: [Color(0xFF7B61FF), Color(0xFF5A3FD9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blue = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF2979FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient green = LinearGradient(
    colors: [Color(0xFF69F0AE), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pink = LinearGradient(
    colors: [Color(0xFFFF6090), Color(0xFFE040FB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFFFD740), Color(0xFFFF9100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgSubtle = LinearGradient(
    colors: [Color(0xFFFAF3E7), Color(0xFFF1DFC5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardShine = LinearGradient(
    colors: [Color(0x08FFFFFF), Color(0x00FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentPurple,
        secondary: AppColors.accentBlue,
        surface: AppColors.bgCard,
        error: AppColors.accentRed,
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.ink, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
