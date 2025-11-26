import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  final List<String> buttons;
  final int crossAxisCount;
  final Function(String) onTap;
  final void Function(String)? onLongPress;

  const ButtonGrid({
    super.key,
    required this.buttons,
    required this.crossAxisCount,
    required this.onTap,
    this.onLongPress,
  });

  bool _isOperator(String s) {
    const ops = {
      "+",
      "-",
      "×",
      "÷",
      "=",
      "^",
      "sin",
      "cos",
      "tan",
      "Ln",
      "log",
      "log2",
      "√",
      "x²",
      "x^y",
      "AND",
      "OR",
      "XOR",
      "NOT",
      "BIN",
      "OCT",
      "DEC",
      "HEX",
      "C",
      "CE",
      "⌫",
      "(",
      ")",
      "%",
      "π",
      "±",
      "2nd"
    };
    return ops.contains(s);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: buttons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDimens.buttonSpacing,
        mainAxisSpacing: AppDimens.buttonSpacing,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (_, i) {
        final label = buttons[i];
        return CalculatorButton(
          label: label,
          onTap: () => onTap(label),
          onLongPress:
          onLongPress == null ? null : () => onLongPress!(label),
          isOperator: _isOperator(label),
          isAccent: label == "=",
        );
      },
    );
  }
}
