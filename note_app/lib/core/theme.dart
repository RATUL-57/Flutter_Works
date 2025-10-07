import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fontSizeProvider = StateProvider<double>((ref) => 16.0);

enum AppThemeMode { light, dark }
final themeModeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.light);

ThemeData appTheme(double fontSize) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: fontSize),
      bodyLarge: TextStyle(fontSize: fontSize + 2),
      titleLarge: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold),
    ),
  );
}

ThemeData appDarkTheme(double fontSize) {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    useMaterial3: true,
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: fontSize),
      bodyLarge: TextStyle(fontSize: fontSize + 2),
      titleLarge: TextStyle(fontSize: fontSize + 4, fontWeight: FontWeight.bold),
    ),
  );
}