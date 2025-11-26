import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

import '../models/calculator_settings.dart';

class ExpressionParser {
  final Parser _parser = Parser();
  final ContextModel _cm = ContextModel();

  double eval(String input, {required AngleMode angleMode}) {
    String exp = _preprocess(input, angleMode: angleMode);

    final expression = _parser.parse(exp);
    double result = expression.evaluate(EvaluationType.REAL, _cm);

    if (result.isInfinite || result.isNaN) {
      throw Exception("Math Error");
    }

    // Nếu là asin/acos/atan và đang ở DEG thì đổi sang độ (đơn giản)
    if (angleMode == AngleMode.degrees && _isPureInverseTrig(input)) {
      result = result * 180 / math.pi;
    }

    return result;
  }

  bool _isPureInverseTrig(String raw) {
    final s = raw.replaceAll(' ', '');
    return s.startsWith('asin(') ||
        s.startsWith('acos(') ||
        s.startsWith('atan(');
  }

  String _preprocess(String input, {required AngleMode angleMode}) {
    String exp = input.replaceAll(' ', '');

    // Chuẩn hoá toán tử
    exp = exp.replaceAll("×", "*");
    exp = exp.replaceAll("÷", "/");

    // Factorial cho số nguyên: 5! -> 120
    exp = exp.replaceAllMapped(RegExp(r'(\d+)!'), (m) {
      final n = int.parse(m[1]!);
      return _fact(n).toString();
    });
    if (RegExp(r'\)!').hasMatch(exp)) {
      throw Exception("Factorial only for integers");
    }

    // Hàm log / ln / log2
    exp = exp.replaceAll("Ln(", "ln(");
    exp = exp.replaceAll("ln(", "log("); // math_expressions: log = ln
    exp = exp.replaceAll("log(", "log10(");

    // sqrt
    exp = exp.replaceAll("√(", "sqrt(");

    // log2(x) -> log(x)/log(2)
    exp = exp.replaceAllMapped(RegExp(r'log2\(([^()]+)\)'), (m) {
      return "(log(${m[1]})/log(2))";
    });

    // 2(3+4) -> 2*(3+4)
    exp = exp.replaceAllMapped(RegExp(r'(\d|\)|π|e)(\()'), (m) {
      return "${m[1]}*${m[2]}";
    });

    // 2sin(x) -> 2*sin(x)
    exp = exp.replaceAllMapped(
      RegExp(
          r'(\d|\)|π|e)(sin|cos|tan|asin|acos|atan|log10|log|sqrt)'),
          (m) => "${m[1]}*${m[2]}",
    );

    // )( hoặc )2 -> )*2
    exp = exp.replaceAllMapped(RegExp(r'(\))(\d|π|e)'), (m) {
      return "${m[1]}*${m[2]}";
    });

    // 2π, 2e, π2, e2
    exp = exp.replaceAllMapped(RegExp(r'(\d)(π|e)'), (m) {
      return "${m[1]}*${m[2]}";
    });
    exp = exp.replaceAllMapped(RegExp(r'(π|e)(\d)'), (m) {
      return "${m[1]}*${m[2]}";
    });

    // Hằng số
    exp = exp.replaceAll("π", "${math.pi}");
    exp = exp.replaceAll("e", "${math.e}");

    // Độ -> rad cho sin/cos/tan
    if (angleMode == AngleMode.degrees) {
      exp = exp.replaceAllMapped(
        RegExp(r'(sin|cos|tan)\(([^()]+)\)'),
            (m) => "${m[1]}((${m[2]})*${math.pi}/180)",
      );
    }

    return exp;
  }

  int _fact(int n) {
    if (n < 0) throw Exception("Factorial error");
    if (n <= 1) return 1;
    return n * _fact(n - 1);
  }
}
