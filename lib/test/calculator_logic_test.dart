import 'package:flutter_test/flutter_test.dart';
import 'package:calculator_app/utils/calculator_logic.dart';
import 'package:calculator_app/utils/expression_parser.dart';
import 'package:calculator_app/models/calculator_settings.dart';

void main() {
  // Dùng chung 1 instance cho tất cả test
  final calculator = CalculatorLogic(ExpressionParser());

  group('Basic arithmetic operations', () {
    test('simple + - * /', () {
      expect(
        calculator.calculate(
          '5 + 3',
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        '8',
      );

      expect(
        calculator.calculate(
          '10 - 4',
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        '6',
      );

      expect(
        calculator.calculate(
          '6 × 7',
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        '42',
      );

      expect(
        calculator.calculate(
          '15 ÷ 3',
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        '5',
      );
    });
  });

  group('Order of operations (PEMDAS)', () {
    test('2 + 3 × 4 = 14', () {
      expect(
        calculator.calculate(
          '2 + 3 × 4',
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        '14',
      );
    });

    test('(2 + 3) × 4 = 20', () {
      expect(
        calculator.calculate(
          '(2 + 3) × 4',
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        '20',
      );
    });
  });

  group('Scientific functions', () {
    test('sin(30°) = 0.5', () {
      expect(
        calculator.calculate(
          'sin(30)',
          angleMode: AngleMode.degrees, // DEG
          precision: 3,
        ),
        '0.5', // 0.500 -> 0.5
      );
    });

    test('√16 = 4', () {
      expect(
        calculator.calculate(
          '√(16)',
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        '4',
      );
    });
  });

  group('Edge cases', () {
    test('Division by zero throws error', () {
      expect(
            () => calculator.calculate(
          '5 ÷ 0',
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        throwsException,
      );
    });

    test('Invalid input throws error', () {
      expect(
            () => calculator.calculate(
          '√(-4)', // sqrt của số âm
          angleMode: AngleMode.degrees,
          precision: 2,
        ),
        throwsException,
      );
    });
  });
}
