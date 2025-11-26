import 'package:flutter/material.dart';

import '../models/calculator_mode.dart';
import '../utils/constants.dart';

class ModeSelector extends StatelessWidget {
  final CalculatorMode mode;
  final Function(CalculatorMode) onSelect;

  const ModeSelector({
    super.key,
    required this.mode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget item(String text, CalculatorMode m) {
      final active = mode == m;

      return Expanded(
        child: AnimatedContainer(
          duration: AppDurations.modeSwitch,
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: () => onSelect(m),
            style: ElevatedButton.styleFrom(
              backgroundColor: active ? cs.tertiary : cs.secondary,
              foregroundColor: active ? Colors.white : cs.onSecondary,
              elevation: active ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(AppDimens.buttonRadius),
              ),
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        item("Basic", CalculatorMode.basic),
        const SizedBox(width: 8),
        item("Sci", CalculatorMode.scientific),
        const SizedBox(width: 8),
        item("Prog", CalculatorMode.programmer),
      ],
    );
  }
}
