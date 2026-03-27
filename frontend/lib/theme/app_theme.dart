import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color electricBlue = Color(0xFF0A84FF);
  static const Color cyan = Color(0xFF16C1D9);
  static const Color deepNavy = Color(0xFF0A1023);
  static const Color steel = Color(0xFF1B2845);
  static const Color danger = Color(0xFFFF4D5A);
  static const Color warning = Color(0xFFFFA726);
  static const Color success = Color(0xFF29C76F);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF16C1D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: electricBlue,
        brightness: Brightness.light,
        primary: electricBlue,
        secondary: cyan,
        error: danger,
      ),
    );

    final textTheme = GoogleFonts.soraTextTheme(base.textTheme).copyWith(
      bodyMedium: GoogleFonts.manrope(textStyle: base.textTheme.bodyMedium),
      bodyLarge: GoogleFonts.manrope(textStyle: base.textTheme.bodyLarge),
      labelLarge: GoogleFonts.manrope(textStyle: base.textTheme.labelLarge),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFFF2F6FC),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F1D40),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD7E3F5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD7E3F5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: electricBlue, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: electricBlue.withOpacity(0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? electricBlue : const Color(0xFF5B6782),
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cyan,
        brightness: Brightness.dark,
        primary: cyan,
        secondary: electricBlue,
        error: danger,
      ),
    );

    final textTheme = GoogleFonts.soraTextTheme(base.textTheme).copyWith(
      bodyMedium: GoogleFonts.manrope(textStyle: base.textTheme.bodyMedium),
      bodyLarge: GoogleFonts.manrope(textStyle: base.textTheme.bodyLarge),
      labelLarge: GoogleFonts.manrope(textStyle: base.textTheme.labelLarge),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF060B16),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE9F1FF),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF121D33),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121D33),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2D3957)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2D3957)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cyan, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: const Color(0xFF0B1426),
        indicatorColor: cyan.withOpacity(0.2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
