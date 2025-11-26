import '../models/calculator_settings.dart';
import 'expression_parser.dart';

class CalculatorLogic {
  final ExpressionParser parser;
  CalculatorLogic(this.parser);

  String append(String expr, String value) => expr + value;

  String backspace(String expr) =>
      expr.isEmpty ? "" : expr.substring(0, expr.length - 1);

  String clear() => "";

  String calculate(
      String expr, {
        required AngleMode angleMode,
        required int precision,
      }) {
    final res = parser.eval(expr, angleMode: angleMode);
    return res
        .toStringAsFixed(precision)
        .replaceAll(RegExp(r'\.?0+$'), '');
  }
}
