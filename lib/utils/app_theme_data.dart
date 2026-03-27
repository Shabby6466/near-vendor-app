import 'package:flutter/material.dart';
import 'package:nearvendorapp/gen/colors.gen.dart';
import 'package:nearvendorapp/gen/fonts.gen.dart';

class AppThemeData {
  AppThemeData._();

  // --- BRAND COLORS ---
  static const Color emerald = Color(0xFF34C759);
  static const Color obsidian = Color(0xFF0C0C11);
  static const Color midnight = Color(0xFF171D25);
  static const Color darkGrey = Color(0xFF1C1C23);

  static const String _fontFamily = FontFamily.poppins;

  static final _appBarTheme = const AppBarTheme(
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

  // --- NORMAL THEMES (Standard Blue) ---
  static ThemeData get normalLightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: ColorName.primary,
        fontFamily: _fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: _appBarTheme.copyWith(
          foregroundColor: const Color(0xFF1D1D1F),
        ),
        cardColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorName.primary,
          brightness: Brightness.light,
          primary: ColorName.primary,
          secondary: ColorName.secondary,
        ),
        inputDecorationTheme: _inputDecorationTheme.copyWith(
          fillColor: Colors.white,
        ),
      );

  static ThemeData get normalDarkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: ColorName.primary,
        fontFamily: _fontFamily,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: _appBarTheme.copyWith(
          foregroundColor: Colors.white,
        ),
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
      );

  // --- VENDOR THEMES (Emerald Signature) ---
  static ThemeData get vendorLightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: emerald,
        fontFamily: _fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF2F9F3), // Subtle emerald tint
        appBarTheme: _appBarTheme.copyWith(
          foregroundColor: const Color(0xFF1D1D1F),
        ),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE8F3EA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
          brightness: Brightness.light,
          primary: emerald,
          secondary: ColorName.primary,
          surfaceTint: Colors.white,
        ),
        inputDecorationTheme: _inputDecorationTheme.copyWith(
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: emerald,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );

  static ThemeData get vendorDarkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: emerald,
        fontFamily: _fontFamily,
        scaffoldBackgroundColor: obsidian,
        appBarTheme: _appBarTheme.copyWith(
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF16161D),
        dividerColor: Colors.white.withOpacity(0.05),
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
          brightness: Brightness.dark,
          primary: emerald,
          secondary: const Color(0xFF30D158),
          surface: const Color(0xFF16161D),
        ),
        inputDecorationTheme: _inputDecorationTheme.copyWith(
          fillColor: darkGrey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: emerald,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      );
}
