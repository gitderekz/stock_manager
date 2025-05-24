import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  primaryColor: const Color(0xFF461B93),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF6A3CBC),
    secondary: Color(0xFF8253D7),
    tertiary: Color(0xFFD4ADFC),
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F6FA),
  cardColor: const Color(0xFFFFFFFF),
  textTheme: const TextTheme(
    displayMedium: TextStyle(color: Color(0xFF2D3436)),
  ),
);

final darkTheme = ThemeData(
  primaryColor: const Color(0xFF6A3CBC),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF8253D7),
    secondary: Color(0xFFD4ADFC),
    tertiary: Color(0xFF461B93),
  ),
  scaffoldBackgroundColor: const Color(0xFF1E1E1E),
  cardColor: const Color(0xFF2D2D2D),
  textTheme: const TextTheme(
    displayMedium: TextStyle(color: Color(0xFFFFFFFF)),
  ),
);
