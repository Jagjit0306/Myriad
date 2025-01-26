import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF010101), // Slightly lighter for better contrast
    onSurface: Colors.white,
    primary: Color.fromARGB(255, 19, 19, 19),
    secondary: Color.fromARGB(255, 44, 44, 44),
    inversePrimary: Color(0xFFFFFFFF),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey[300],
    displayColor: Colors.white,
  ),
  applyElevationOverlayColor: true, // Enables overlay for elevation
);

LinearGradient darkGradient = const LinearGradient(
  colors: [
    Color(0xFF131313),
    Color(0xFF0C0C0C),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

