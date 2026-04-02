import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary    = Color(0xFF4A6CF7);
  static const Color primarySoft= Color(0xFFEEF2FF);
  static const Color accent     = Color(0xFF06D6A0);
  static const Color accentSoft = Color(0xFFE8FDF6);
  static const Color error      = Color(0xFFFF4F6E);
  static const Color errorSoft  = Color(0xFFFFECF0);
  static const Color warning    = Color(0xFFFFA94D);
  static const Color bg         = Color(0xFFF5F7FF);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color card       = Color(0xFFFFFFFF);
  static const Color textDark   = Color(0xFF1A1F3C);
  static const Color textMid    = Color(0xFF6B7280);
  static const Color textLight  = Color(0xFFB0B7C3);
  static const Color divider    = Color(0xFFEEF1FF);

  static ThemeData get light {
    final base = GoogleFonts.poppinsTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      textTheme: base.copyWith(
        displayLarge:  GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -1.5),
        displayMedium: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: textDark, letterSpacing: -1),
        displaySmall:  GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: textDark),
        headlineLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: textDark),
        headlineMedium:GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: textDark),
        headlineSmall: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        titleLarge:    GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textDark),
        titleMedium:   GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: textDark),
        bodyLarge:     GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: textDark),
        bodyMedium:    GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: textMid),
        bodySmall:     GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: textLight),
        labelLarge:    GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        shadowColor: primary.withOpacity(0.08),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}