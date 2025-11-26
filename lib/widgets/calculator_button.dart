import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CalculatorButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isOperator;
  final bool isAccent;

  const CalculatorButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.isOperator = false,
    this.isAccent = false,
  });

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bgColor = widget.isAccent
        ? cs.tertiary
        : widget.isOperator
        ? cs.primary.withOpacity(0.12)
        : cs.secondary;

    final textColor = widget.isAccent
        ? Colors.white
        : widget.isOperator
        ? cs.tertiary
        : cs.onSecondary;

    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) {
        setState(() => pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => pressed = false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        duration: AppDurations.buttonPress,
        scale: pressed ? 0.94 : 1,
        child: AnimatedContainer(
          duration: AppDurations.buttonPress,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
            boxShadow: pressed
                ? []
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
