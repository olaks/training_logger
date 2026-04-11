import 'package:flutter/material.dart';

const _bg      = Color(0xFF121212);
const _surface = Color(0xFF1E1E1E);
const _card    = Color(0xFF252525);

/// Named accent options the user can choose from.
const themeAccents = [
  (name: 'Forest', color: Color(0xFF43A047)),
  (name: 'Ocean',  color: Color(0xFF1E88E5)),
  (name: 'Dusk',   color: Color(0xFF7E57C2)),
  (name: 'Ember',  color: Color(0xFFFF7043)),
];

ThemeData buildTheme(Color primary) => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary:                 primary,
    onPrimary:               Colors.black,
    surface:                 _surface,
    surfaceContainerHighest: _card,
    error:                   const Color(0xFFD32F2F),
  ),
  scaffoldBackgroundColor: _bg,
  cardTheme: const CardThemeData(color: _surface, elevation: 0, margin: EdgeInsets.zero),
  appBarTheme: const AppBarTheme(backgroundColor: _surface, elevation: 0, scrolledUnderElevation: 0),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: _surface,
    indicatorColor: primary.withValues(alpha: 0.2),
  ),
  tabBarTheme: TabBarThemeData(
    labelColor: primary,
    unselectedLabelColor: const Color(0xFF757575),
    indicatorColor: primary,
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
      backgroundColor: primary,
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  ),
);
