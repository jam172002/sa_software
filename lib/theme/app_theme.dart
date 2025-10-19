import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primaryBlue = Color(0xFF1677FF);
  const surface = Colors.white;
  const textColor = Color(0xFF111827);

  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: primaryBlue,
      secondary: const Color(0xFF1E6AF6),
      surface: surface,
      onSurface: textColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    dataTableTheme: const DataTableThemeData(
      headingRowHeight: 44,
      dataRowMinHeight: 44,
      dataRowMaxHeight: 48,
    ),
  );
}
