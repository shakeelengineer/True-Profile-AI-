import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF3EE0CF); // Vibrant Cyan
  static const Color secondaryColor = Color(0xFF1AA2E6); // Sky Blue (for gradients)
  static const Color backgroundColor = Color(0xFF080C16); // Deep Navy
  static const Color surfaceColor = Color(0xFF191F2E); // Dark Blue-Gray
  static const Color borderColor = Color(0xFF20283C); // Muted Blue

  static const Color textPrimary = Color(0xFFF8FAFC); // Off-white
  static const Color textSecondary = Color(0xFF94A3B8); // Slate Gray

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.outfit().fontFamily,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.outfitTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: backgroundColor,
        backgroundColor: primaryColor,
        elevation: 0,
        textStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textSecondary),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      margin: const EdgeInsets.only(bottom: 16),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
  );

  // For this design system, we mainly focus on the dark mode aesthetic
  // so we'll map darkTheme to be similar or the same as standard theme if usage dictates
  static final ThemeData darkTheme = lightTheme; 
}
