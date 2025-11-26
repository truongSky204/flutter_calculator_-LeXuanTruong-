import 'package:flutter/material.dart';

import '../models/calculation_history.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';

import '../services/storage_service.dart';
import '../utils/calculator_logic.dart';
import '../utils/expression_parser.dart';
import 'history_provider.dart';

class CalculatorProvider extends ChangeNotifier {
  // State
  String _expression = '';
  String _result = '0';

  String lastExpression = '';
  String lastResult = '';

  CalculatorMode _mode = CalculatorMode.basic;
  AngleMode _angleMode = AngleMode.degrees;

  double _memory = 0;
  bool _hasMemory = false;

  bool hasError = false;
  double _fontScale = 1.0;

  // Getters
  String get expression => _expression;
  String get result => _result;
  CalculatorMode get mode => _mode;
  AngleMode get angleMode => _angleMode;
  double get memory => _memory;
  bool get hasMemory => _hasMemory;
  double get fontScale => _fontScale;

  // Services
  final StorageService storage;
  final HistoryProvider historyProvider;
  late CalculatorLogic logic;

  CalculatorSettings settings = CalculatorSettings.defaults();

  CalculatorProvider({
    required this.storage,
    required this.historyProvider,
  }) {
    logic = CalculatorLogic(ExpressionParser());
    _init();
  }

  Future<void> _init() async {
    settings = await storage.loadSettings();
    _angleMode = settings.angleMode;

    _mode = await storage.loadCalculatorMode();
    _memory = await storage.loadMemory();
    _hasMemory = _memory != 0;

    notifyListeners();
  }

  // -------- Core Methods --------

  void addToExpression(String value) {
    hasError = false;

    if (value == "C") return clear();
    if (value == "CE") return clearEntry();
    if (value == "⌫") {
      deleteLastChar();
      return;
    }
    if (value == "±") return toggleSign();
    if (value == "%") return addPercentage();

    // Scientific mapping
    value = _mapScientificToken(value);

    if (value == "=") return calculate();

    _expression = logic.append(_expression, value);
    _result = _expression.isEmpty ? "0" : _expression;
    notifyListeners();
  }

  void calculate() {
    if (_expression.isEmpty) return;
    try {
      final res = logic.calculate(
        _expression,
        angleMode: _angleMode,
        precision: settings.precision,
      );

      lastExpression = _expression;
      lastResult = res;

      historyProvider.add(
        CalculationHistory(
          expression: lastExpression,
          result: lastResult,
        ),
      );

      _result = res;
      _expression = res;
      hasError = false;
      notifyListeners();
    } catch (_) {
      _result = "Error";
      hasError = true;
      notifyListeners();
    }
  }

  void clear() {
    _expression = '';
    _result = '0';
    hasError = false;
    notifyListeners();
  }

  void clearEntry() {
    _expression = _expression.replaceFirst(RegExp(r'[\d.]+$'), '');
    _result = _expression.isEmpty ? "0" : _expression;
    notifyListeners();
  }

  void toggleSign() {
    if (_expression.startsWith("-")) {
      _expression = _expression.substring(1);
    } else {
      _expression = "-$_expression";
    }
    _result = _expression.isEmpty ? "0" : _expression;
    notifyListeners();
  }

  void addPercentage() {
    _expression += "/100";
    _result = _expression;
    notifyListeners();
  }

  void addScientificFunction(String function) {
    addToExpression(function);
  }

  void toggleMode(CalculatorMode mode) async {
    _mode = mode;
    await storage.saveCalculatorMode(mode);
    notifyListeners();
  }

  void toggleAngleMode() async {
    _angleMode = _angleMode == AngleMode.degrees
        ? AngleMode.radians
        : AngleMode.degrees;

    settings = settings.copyWith(angleMode: _angleMode);
    await storage.saveSettings(settings);
    notifyListeners();
  }

  // -------- Memory --------

  void memoryAdd() async {
    _memory += double.tryParse(_result) ?? 0;
    _hasMemory = true;
    await storage.saveMemory(_memory);
    notifyListeners();
  }

  void memorySubtract() async {
    _memory -= double.tryParse(_result) ?? 0;
    _hasMemory = true;
    await storage.saveMemory(_memory);
    notifyListeners();
  }

  void memoryRecall() {
    addToExpression(_memory.toString());
  }

  void memoryClear() async {
    _memory = 0;
    _hasMemory = false;
    await storage.saveMemory(_memory);
    notifyListeners();
  }

  // -------- Gestures --------

  void deleteLastChar() {
    _expression = logic.backspace(_expression);
    _result = _expression.isEmpty ? "0" : _expression;
    notifyListeners();
  }

  void updateFontScale(double scale) {
    _fontScale = scale.clamp(0.8, 1.4);
    notifyListeners();
  }

  void reuseExpression(String expr) {
    _expression = expr;
    _result = expr.isEmpty ? "0" : expr;
    hasError = false;
    notifyListeners();
  }

  // -------- Helpers --------

  String _mapScientificToken(String v) {
    switch (v) {
      case "sin":
        return "sin(";
      case "cos":
        return "cos(";
      case "tan":
        return "tan(";
      case "asin":
        return "asin(";
      case "acos":
        return "acos(";
      case "atan":
        return "atan(";
      case "Ln":
        return "Ln(";
      case "log":
        return "log(";
      case "log2":
        return "log2(";
      case "√":
        return "√(";
      case "x²":
        return "^2";
      case "x^y":
        return "^";
      case "π":
        return "π";
      case "e":
        return "e";
      case "n!":
        return "!";
      default:
        return v;
    }
  }
}
