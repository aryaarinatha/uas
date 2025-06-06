import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ValueNotifier selectedThemeNotifier = ValueNotifier(false);

final ThemeData lightTheme = ThemeData.light().copyWith(
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: ColorScheme.light(
    primary: Colors.brown.shade700,
    secondary: Colors.brown.shade200,
    surface: Colors.white,
    error: Colors.red,
    onPrimary: Colors.white,
    onSecondary: Colors.brown.shade900,
    onSurface: Colors.brown.shade900,
    onError: Colors.white,
    brightness: Brightness.light,
  ),
);
          
final ThemeData darkTheme = ThemeData.dark().copyWith(
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: ColorScheme.dark(
    primary: Colors.brown.shade400,
    secondary: Colors.brown.shade800,
    surface: Colors.brown.shade900,
    error: Colors.red,
    onPrimary: Colors.brown.shade100,
    onSecondary: Colors.brown.shade100,
    onSurface: Colors.brown.shade100,
    onError: Colors.brown.shade100,
    brightness: Brightness.dark,
  ),
);