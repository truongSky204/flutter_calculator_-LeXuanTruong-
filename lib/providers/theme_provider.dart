import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService storage;
  ThemeProvider(this.storage);

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      tertiary: AppColors.lightAccent,
      surface: Color(0xFFF5F5F5),
    ),
    fontFamily: 'Roboto',
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkPrimary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      tertiary: AppColors.darkAccent,
      surface: Color(0xFF1E1E1E),
    ),
    fontFamily: 'Roboto',
  );

  Future<void> load() async {
    _themeMode = await storage.loadThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else {
      await setTheme(ThemeMode.light);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    await storage.saveThemeMode(mode);
    notifyListeners();
  }
}
