import 'package:flutter/material.dart';

const _green   = Color(0xFF43A047);
const _bg      = Color(0xFF121212);
const _surface = Color(0xFF1E1E1E);
const _card    = Color(0xFF252525);

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary:           _green,
    onPrimary:         Colors.black,
    surface:           _surface,
    surfaceContainerHighest: _card,
    error:             const Color(0xFFD32F2F),
  ),
  scaffoldBackgroundColor: _bg,
  cardTheme: const CardThemeData(color: _surface, elevation: 0, margin: EdgeInsets.zero),
  appBarTheme: const AppBarTheme(backgroundColor: _surface, elevation: 0, scrolledUnderElevation: 0),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: _surface,
    indicatorColor: _green.withValues(alpha: 0.2),
  ),
  tabBarTheme: const TabBarThemeData(
    labelColor: _green,
    unselectedLabelColor: Color(0xFF757575),
    indicatorColor: _green,
    dividerColor: Colors.transparent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  ),
  dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08), thickness: 0.5),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _green,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  ),
);
