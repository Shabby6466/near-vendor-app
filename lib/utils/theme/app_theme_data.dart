import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/gen/fonts.gen.dart';

class AppThemeData {
  AppThemeData._();

  static const Color obsidian = Color(0xFF21242A);
  static const Color midnight = Color(0xFF171D25);
  static const Color darkGrey = Color(0xFF1C1C23);

  static const String _fontFamily = FontFamily.poppins;

  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subColor = isDark ? Colors.white70 : Colors.black54;

    return TextTheme(
      displayLarge: TextStyle(fontFamily: _fontFamily, color: textColor),
      displayMedium: TextStyle(fontFamily: _fontFamily, color: textColor),
      displaySmall: TextStyle(fontFamily: _fontFamily, color: textColor),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: TextStyle(fontFamily: _fontFamily, color: textColor),
      bodyMedium: TextStyle(fontFamily: _fontFamily, color: textColor),
      bodySmall: TextStyle(fontFamily: _fontFamily, color: subColor),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelMedium: TextStyle(fontFamily: _fontFamily, color: subColor),
      labelSmall: TextStyle(fontFamily: _fontFamily, color: subColor),
    );
  }

  static const _appBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
  );

  static final _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );

  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorName.primary,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData get normalLightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: ColorName.primary,
    fontFamily: _fontFamily,
    textTheme: _buildTextTheme(Brightness.light),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: _appBarTheme.copyWith(
      foregroundColor: const Color(0xFF1D1D1F),
    ),
    cardColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorName.primary,
      primary: ColorName.primary,
      secondary: ColorName.secondary,
    ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      fillColor: Colors.white,
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
  );

  static ThemeData get normalDarkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: ColorName.primary,
    fontFamily: _fontFamily,
    textTheme: _buildTextTheme(Brightness.dark),
    scaffoldBackgroundColor: obsidian,
    appBarTheme: _appBarTheme.copyWith(foregroundColor: Colors.white),
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: ColorScheme.fromSeed(
      seedColor: ColorName.primary,
      brightness: Brightness.dark,
      primary: ColorName.primary,
      secondary: ColorName.secondary,
      surface: const Color(0xFF1E1E1E),
    ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      fillColor: const Color(0xFF2C2C2E),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
  );
}
