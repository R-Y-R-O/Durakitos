
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Hacemos el seed color una constante para fácil acceso y consistencia
  static const Color _seedColor = Color(0xFF005FFF); // Un azul vibrante y moderno

  // --- TEMA CLARO ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      primary: _seedColor, // El color principal para botones, etc.
      onPrimary: Colors.white, // Color del texto sobre el color primario
      secondary: Colors.amber, // Un color de acento
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Un gris muy claro para el fondo
    appBarTheme: AppBarTheme(
      backgroundColor: _seedColor,
      foregroundColor: Colors.white, // Color del título y los iconos
      elevation: 2,
      titleTextStyle: GoogleFonts.nunito(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    textTheme: _textTheme(Brightness.light),
    elevatedButtonTheme: _elevatedButtonTheme(_seedColor, Brightness.light),
    inputDecorationTheme: _inputDecorationTheme(Brightness.light),
  );

  // --- TEMA OSCURO ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      primary: _seedColor,
      onPrimary: Colors.white,
      secondary: Colors.amberAccent,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212), // Fondo oscuro estándar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: GoogleFonts.nunito(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    textTheme: _textTheme(Brightness.dark),
    elevatedButtonTheme: _elevatedButtonTheme(_seedColor, Brightness.dark),
    inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
  );

  // --- WIDGETS COMUNES ---

  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? Colors.black87 : Colors.white;
    return TextTheme(
      displayLarge: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 32, color: color),
      titleLarge: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 24, color: color),
      bodyLarge: GoogleFonts.openSans(fontSize: 16, color: color),
      bodyMedium: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[600]),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color seedColor, Brightness brightness) {
    final backgroundColor = brightness == Brightness.light ? seedColor : seedColor.withOpacity(0.8);
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final borderColor = brightness == Brightness.light ? Colors.grey[400] : Colors.grey[700];
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light ? Colors.white : Colors.grey[800],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _seedColor, width: 2),
      ),
    );
  }
}
