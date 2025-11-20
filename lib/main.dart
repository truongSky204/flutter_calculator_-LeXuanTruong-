import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// App gốc
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      theme: ThemeData(
        primaryColor: const Color(0xFF2D3142), // Primary
        scaffoldBackgroundColor: const Color(0xFF2D3142),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

/// Màn hình máy tính
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // ===== Step 4: State variables =====
  String _display = '0';   // Giá trị đang hiển thị
  String _equation = '';   // Chuỗi phép tính phía trên
  double _num1 = 0;        // Toán hạng 1
  double _num2 = 0;        // Toán hạng 2
  String _operation = '';  // Phép toán hiện tại

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Screen padding: 20px
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // ====== VÙNG HIỂN THỊ ======
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _equation,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _display,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ====== LƯỚI NÚT ======
            _buildButtonGrid(),
          ],
        ),
      ),
    );
  }

  /// Nút máy tính dùng chung
  Widget _buildCalcButton(
      String text, {
        Color? backgroundColor,
        Color? textColor,
        int flex = 1,
      }) {
    backgroundColor ??= const Color(0xFF4F5D75); // Secondary
    textColor ??= Colors.white;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(8), // 8*2 = 16px spacing
        child: SizedBox(
          height: 64,
          child: ElevatedButton(
            onPressed: () => _onButtonPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Lưới nút
  Widget _buildButtonGrid() {
    const accent = Color(0xFFEF8354); // Accent
    final gray = Colors.grey.shade600;

    return Column(
      children: [
        Row(
          children: [
            _buildCalcButton('C', backgroundColor: gray),
            _buildCalcButton('CE', backgroundColor: gray),
            _buildCalcButton('%', backgroundColor: gray),
            _buildCalcButton('÷', backgroundColor: accent),
          ],
        ),
        Row(
          children: [
            _buildCalcButton('7'),
            _buildCalcButton('8'),
            _buildCalcButton('9'),
            _buildCalcButton('×', backgroundColor: accent),
          ],
        ),
        Row(
          children: [
            _buildCalcButton('4'),
            _buildCalcButton('5'),
            _buildCalcButton('6'),
            _buildCalcButton('-', backgroundColor: accent),
          ],
        ),
        Row(
          children: [
            _buildCalcButton('1'),
            _buildCalcButton('2'),
            _buildCalcButton('3'),
            _buildCalcButton('+', backgroundColor: accent),
          ],
        ),
        Row(
          children: [
            _buildCalcButton('±', backgroundColor: gray),
            _buildCalcButton('0'),
            _buildCalcButton('.', backgroundColor: gray),
            _buildCalcButton('=', backgroundColor: accent),
          ],
        ),
      ],
    );
  }

  // ================== STEP 4: LOGIC ==================

  void _onButtonPressed(String text) {
    setState(() {
      if (_isNumber(text)) {
        _onNumberPressed(text);
      } else if (_isOperator(text)) {
        _onOperatorPressed(text);
      } else {
        switch (text) {
          case '=':
            _onEqualsPressed();
            break;
          case 'C':
            _onClearAll();
            break;
          case 'CE':
            _onClearEnd();
            break;
          case '.':
            _onDecimalPressed();
            break;
          case '±':
            _onToggleSign();
            break;
          case '%':
            _onPercentPressed();
            break;
        }
      }
    });
  }

  bool _isNumber(String s) => RegExp(r'^[0-9]$').hasMatch(s);
  bool _isOperator(String s) => s == '+' || s == '-' || s == '×' || s == '÷';

  /// 1) Nhấn số 0–9: nối vào display
  void _onNumberPressed(String digit) {
    if (_display == '0' || _display == 'Error') {
      _display = digit;
    } else {
      if (_display.length < 16) {
        _display += digit;
      }
    }
  }

  /// 2) Nhấn phép toán +, -, ×, ÷
  void _onOperatorPressed(String op) {
    if (_display == 'Error') return;

    // Nếu nhấn liên tiếp nhiều phép toán mà chưa nhập số mới -> chỉ đổi phép toán
    if (_operation.isNotEmpty && _display == '0' && !_equation.endsWith('=')) {
      _operation = op;
      _equation = '$_num1 $op';
      return;
    }

    // Nếu đang có phép toán trước đó -> tính tạm (chain)
    if (_operation.isNotEmpty) {
      _onEqualsPressed();
    }

    _num1 = double.tryParse(_display) ?? 0;
    _operation = op;
    _equation = '$_display $op';
    _display = '0';
  }

  /// 3) Nhấn "="
  void _onEqualsPressed() {
    if (_operation.isEmpty || _display == 'Error') return;

    _num2 = double.tryParse(_display) ?? 0;
    double result;

    switch (_operation) {
      case '+':
        result = _num1 + _num2;
        break;
      case '-':
        result = _num1 - _num2;
        break;
      case '×':
        result = _num1 * _num2;
        break;
      case '÷':
        if (_num2 == 0) {
          _equation = '$_num1 ÷ 0 =';
          _display = 'Error';
          _operation = '';
          return;
        }
        result = _num1 / _num2;
        break;
      default:
        return;
    }

    _equation = '$_num1 $_operation $_num2 =';
    _display = _formatResult(result);

    // cập nhật để có thể chain tiếp
    _num1 = result;
    _operation = '';
  }

  /// Format kết quả: bỏ .0 nếu là số nguyên
  String _formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    // giới hạn chữ số thập phân để tránh dài quá
    final s = value.toString();
    if (s.length > 16) {
      return value.toStringAsPrecision(10);
    }
    return s;
  }

  /// 4) C: reset toàn bộ
  void _onClearAll() {
    _display = '0';
    _equation = '';
    _num1 = 0;
    _num2 = 0;
    _operation = '';
  }

  /// 5) CE: xóa 1 ký tự cuối
  void _onClearEnd() {
    if (_display == 'Error') {
      _display = '0';
      return;
    }
    if (_display.length <= 1) {
      _display = '0';
    } else {
      _display = _display.substring(0, _display.length - 1);
    }
  }

  /// 6) "." : thêm dấu thập phân
  void _onDecimalPressed() {
    if (_display == 'Error') {
      _display = '0.';
      return;
    }
    if (_display.contains('.')) return; // không cho 2 dấu chấm
    _display += '.';
  }

  /// 7) "±" : đổi dấu
  void _onToggleSign() {
    if (_display == '0' || _display == 'Error') return;
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }
  }

  /// 8) "%" : chia 100
  void _onPercentPressed() {
    if (_display == 'Error') return;
    final value = (double.tryParse(_display) ?? 0) / 100;
    _display = _formatResult(value);
  }
}
