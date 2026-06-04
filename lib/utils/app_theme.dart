import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color cardBg = Color.fromARGB(255, 248, 245, 247);
  static const Color accent = Color(0xFF388E3C);
  static const Color lightNavy = Color(0xFFB0C4DE); // Light navy blue
  static const Color darkNavy = Color.fromARGB(255, 48, 54, 61); // Light navy blue
  static const TextStyle cardText1Style = TextStyle(fontSize: 22, fontWeight: FontWeight.bold); //Prayer name in Prayer page
  static const TextStyle cardText2Style = TextStyle(fontSize: 22); //Time in Prayer page
  static const TextStyle cardText3Style = TextStyle(fontSize: 16); //English text in phrases, duas pages


  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: lightNavy,
    
    cardColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: primaryGreen,
      secondary: accent,
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: darkNavy,
    cardColor: Colors.grey[900],
    colorScheme: ColorScheme.dark(
      primary: primaryGreen,
      secondary: accent,
    ),
    fontFamily: 'Roboto',
    useMaterial3: true,
    textTheme: const TextTheme(
      //bodyLarge: TextStyle(color: Colors.black), // For Material 3
      //bodyMedium: TextStyle(color: Colors.black),
      //bodySmall: TextStyle(color: Colors.black),
      //labelSmall: TextStyle(color: Colors.black),
      
    )
  );
}
