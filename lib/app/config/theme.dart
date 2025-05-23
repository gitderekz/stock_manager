import 'package:flutter/material.dart';

class AppTheme {
  // Color definitions
  static const Color primaryColor = Color(0xFF461B93);
  static const Color secondaryColor = Color(0xFF6A3CBC);
  static const Color tertiaryColor = Color(0xFF8253D7);
  static const Color accentColor = Color(0xFFD4ADFC);
  static const Color successColor = Color(0xFF00b894);
  static const Color errorColor = Color(0xFFd63031);
  static const Color warningColor = Color(0xFFfdcb6e);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: Color(0xFFf5f6fa),
      background: Color(0xFFffffff),
      onPrimary: Colors.white,
      error: errorColor,
    ),
    scaffoldBackgroundColor: const Color(0xFFf5f6fa),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: errorColor,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: tertiaryColor,
    colorScheme: const ColorScheme.dark(
      primary: tertiaryColor,
      secondary: secondaryColor,
      tertiary: primaryColor,
      surface: Color(0xFF2d2d2d),
      background: Color(0xFF1e1e1e),
      onPrimary: Colors.white,
      error: errorColor,
    ),
    scaffoldBackgroundColor: const Color(0xFF1e1e1e),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2d2d2d),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.zero,
      color: const Color(0xFF2d2d2d),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: errorColor,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}



// import 'package:flutter/material.dart';
//
// class AppTheme {
//   static final ThemeData lightTheme = ThemeData(
//     primaryColor: const Color(0xFF461B93),
//     colorScheme: const ColorScheme.light(
//       primary: Color(0xFF461B93),
//       secondary: Color(0xFF6A3CBC),
//       tertiary: Color(0xFF8253D7),
//       surface: Color(0xFFf5f6fa),
//       background: Color(0xFFffffff),
//       onPrimary: Colors.white,
//     ),
//     scaffoldBackgroundColor: const Color(0xFFf5f6fa),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Color(0xFF461B93),
//       foregroundColor: Colors.white,
//       elevation: 0,
//     ),
//     cardTheme: CardTheme(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       margin: EdgeInsets.zero,
//     ),
//   );
//
//   static final ThemeData darkTheme = ThemeData(
//     primaryColor: const Color(0xFF8253D7),
//     colorScheme: const ColorScheme.dark(
//       primary: Color(0xFF8253D7),
//       secondary: Color(0xFF6A3CBC),
//       tertiary: Color(0xFF461B93),
//       surface: Color(0xFF2d2d2d),
//       background: Color(0xFF1e1e1e),
//       onPrimary: Colors.white,
//     ),
//     scaffoldBackgroundColor: const Color(0xFF1e1e1e),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: Color(0xFF2d2d2d),
//       elevation: 0,
//     ),
//     cardTheme: CardTheme(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       margin: EdgeInsets.zero,
//       color: const Color(0xFF2d2d2d),
//     ),
//   );
// }