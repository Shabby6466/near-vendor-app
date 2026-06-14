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

  static InputDecorationTheme _buildInputDecorationTheme(
    Brightness brightness,
  ) {
    final bool isDark = brightness == Brightness.dark;
    final Color fillColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final Color hintColor = isDark ? Colors.white54 : Colors.black45;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: hintColor,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(
    Brightness brightness,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorName.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(Brightness brightness) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color outlineColor = isDark ? Colors.white30 : Colors.black26;

    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: const StadiumBorder(),
        side: BorderSide(color: outlineColor),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

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
    inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
    elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
    textButtonTheme: _buildTextButtonTheme(Brightness.light),
    outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
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
    inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
    elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
    textButtonTheme: _buildTextButtonTheme(Brightness.dark),
    outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
  );
}
