import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';

import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';

import '../widgets/display_area.dart';
import '../widgets/button_grid.dart';
import '../widgets/mode_selector.dart';

import '../utils/constants.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  // ===== BUTTON LAYOUT =====

  List<String> _basicButtons() => [
    "C",
    "CE",
    "%",
    "÷",
    "7",
    "8",
    "9",
    "×",
    "4",
    "5",
    "6",
    "-",
    "1",
    "2",
    "3",
    "+",
    "±",
    "0",
    ".",
    "=",
  ];

  List<String> _scientificButtons() => [
    "2nd",
    "sin",
    "cos",
    "tan",
    "Ln",
    "log",
    "x²",
    "√",
    "x^y",
    "(",
    ")",
    "÷",
    "MC",
    "7",
    "8",
    "9",
    "C",
    "×",
    "MR",
    "4",
    "5",
    "6",
    "CE",
    "-",
    "M+",
    "1",
    "2",
    "3",
    "%",
    "+",
    "M-",
    "±",
    "0",
    ".",
    "π",
    "=",
  ];

  List<String> _programmerButtons() => [
    "BIN",
    "OCT",
    "DEC",
    "HEX",
    "AND",
    "OR",
    "XOR",
    "NOT",
    "<<",
    ">>",
    "(",
    ")",
    "7",
    "8",
    "9",
    "÷",
    "4",
    "5",
    "6",
    "×",
    "1",
    "2",
    "3",
    "-",
    "0",
    ".",
    "=",
    "+",
  ];

  int _crossAxisCount(CalculatorMode mode) {
    switch (mode) {
      case CalculatorMode.scientific:
        return 6;
      case CalculatorMode.programmer:
        return 4;
      default:
        return 4;
    }
  }

  List<String> _buttonsForMode(CalculatorMode mode) {
    switch (mode) {
      case CalculatorMode.scientific:
        return _scientificButtons();
      case CalculatorMode.programmer:
        return _programmerButtons();
      default:
        return _basicButtons();
    }
  }

  // ===== HANDLE TAP =====

  void _handleTap(BuildContext context, String label) {
    final calc = context.read<CalculatorProvider>();

    // Memory
    if (label == "MC") return calc.memoryClear();
    if (label == "MR") return calc.memoryRecall();
    if (label == "M+") return calc.memoryAdd();
    if (label == "M-") return calc.memorySubtract();

    if (label == "2nd") return; // chưa xử lý

    calc.addToExpression(label);
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final theme = context.watch<ThemeProvider>();
    final history = context.watch<HistoryProvider>();

    final buttons = _buttonsForMode(calc.mode);
    final cols = _crossAxisCount(calc.mode);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ModeSelector(
                    mode: calc.mode,
                    onSelect: calc.toggleMode,
                  ),
                ),
                IconButton(
                  onPressed: theme.toggleTheme,
                  icon: Icon(
                    theme.themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.settings),
                ),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.history),
                ),
              ],
            ),

            const SizedBox(height: 12),

            DisplayArea(
              expression: calc.expression,
              result: calc.result,
              previousResult: calc.lastExpression,
              hasError: calc.hasError,
              angleDegrees: calc.angleMode == AngleMode.degrees,
              memoryStored: calc.hasMemory,
              previewItems: history.items,
              onSelectHistory: calc.reuseExpression,
              onSwipeRight: calc.deleteLastChar,
              onSwipeUp: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              ),
              onScaleUpdate: calc.updateFontScale,
              fontScale: calc.fontScale,
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ButtonGrid(
                buttons: buttons,
                crossAxisCount: cols,
                onTap: (label) => _handleTap(context, label),
                onLongPress: (label) {
                  if (label == "C") {
                    context.read<HistoryProvider>().clearAll();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
