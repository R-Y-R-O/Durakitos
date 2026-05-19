
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- COLORES PRIMARIOS (Extraídos de Tailwind) ---
  static const Color primary = Color(0xFF003D9B);
  static const Color primaryContainer = Color(0xFF0052CC);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF535F70);
  static const Color secondaryContainer = Color(0xFFD6E3F7);
  static const Color onSecondaryContainer = Color(0xFF596576);
  static const Color tertiary = Color(0xFF004E32);

  // --- COLORES DE SUPERFICIE ---
  static const Color background = Color(0xFFFAFBFF);
  static const Color surface = Color(0xFFFAFBFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3FD);
  static const Color onSurface = Color(0xFF191B23);
  static const Color onSurfaceVariant = Color(0xFF434654);

  // --- OTROS COLORES ---
  static const Color outline = Color(0xFF737685);
  static const Color outlineVariant = Color(0xFFC3C6D6);
  static const Color error = Color(0xFFBA1A1A);


  static ThemeData get themeData {
    final baseTheme = ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      // --- ESQUEMA DE COLOR ---
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        background: background,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        error: error,
      ),

      // --- TEXTOS (usando Google Fonts) ---
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, color: onSurface),
        headlineMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: onSurface),
        headlineSmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: onSurface),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: onSurfaceVariant),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.05),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.05, color: onSurfaceVariant),
      ),

      // --- ESTILOS DE WIDGETS ---
      scaffoldBackgroundColor: background,

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 1,
        shadowColor: outline.withOpacity(0.1),
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w500, color: primary),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // xl en Tailwind
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // lg en Tailwind
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: onSurfaceVariant),
        filled: true,
        fillColor: surfaceContainerLow,
      ),
    );
  }
}
