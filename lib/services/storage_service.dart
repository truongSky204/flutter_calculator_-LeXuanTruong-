import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';

class StorageService {
  static const _historyKey = "calc_history";
  static const _settingsKey = "calc_settings";

  static const _themeModeKey = "theme_mode";
  static const _modeKey = "calc_mode";
  static const _memoryKey = "calc_memory";

  // -------- HISTORY ----------
  Future<List<CalculationHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final List data = jsonDecode(raw);
    return data.map((e) => CalculationHistory.fromJson(e)).toList();
  }

  Future<void> saveHistory(List<CalculationHistory> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_historyKey, raw);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // -------- SETTINGS (precision + angle mode) ----------
  Future<CalculatorSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return CalculatorSettings.defaults();
    return CalculatorSettings.fromJson(jsonDecode(raw));
  }

  Future<void> saveSettings(CalculatorSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // -------- THEME MODE ----------
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  // -------- CALCULATOR MODE ----------
  Future<void> saveCalculatorMode(CalculatorMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }

  Future<CalculatorMode> loadCalculatorMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_modeKey);
    if (raw == null) return CalculatorMode.basic;
    return CalculatorMode.values.firstWhere(
          (m) => m.name == raw,
      orElse: () => CalculatorMode.basic,
    );
  }

  // -------- MEMORY VALUE ----------
  Future<void> saveMemory(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_memoryKey, value);
  }

  Future<double> loadMemory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_memoryKey) ?? 0.0;
  }
}
