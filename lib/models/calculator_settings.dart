enum AngleMode { degrees, radians }

class CalculatorSettings {
  /// Số chữ số thập phân (2–10)
  final int precision;

  /// Chế độ góc DEG/RAD
  final AngleMode angleMode;

  /// Bật/tắt rung
  final bool hapticFeedback;

  /// Bật/tắt âm thanh
  final bool soundEffects;

  /// Số dòng history lưu: 25/50/100
  final int historySize;

  CalculatorSettings({
    required this.precision,
    required this.angleMode,
    required this.hapticFeedback,
    required this.soundEffects,
    required this.historySize,
  });

  factory CalculatorSettings.defaults() => CalculatorSettings(
    precision: 6,
    angleMode: AngleMode.degrees,
    hapticFeedback: true,
    soundEffects: false,
    historySize: 50,
  );

  Map<String, dynamic> toJson() => {
    "precision": precision,
    "angleMode": angleMode.name,
    "hapticFeedback": hapticFeedback,
    "soundEffects": soundEffects,
    "historySize": historySize,
  };

  factory CalculatorSettings.fromJson(Map<String, dynamic> json) {
    final modeStr = json["angleMode"] ?? "degrees";
    final mode = AngleMode.values.firstWhere(
          (m) => m.name == modeStr,
      orElse: () => AngleMode.degrees,
    );

    return CalculatorSettings(
      precision: json["precision"] ?? 6,
      angleMode: mode,
      hapticFeedback: json["hapticFeedback"] ?? true,
      soundEffects: json["soundEffects"] ?? false,
      historySize: json["historySize"] ?? 50,
    );
  }

  CalculatorSettings copyWith({
    int? precision,
    AngleMode? angleMode,
    bool? hapticFeedback,
    bool? soundEffects,
    int? historySize,
  }) {
    return CalculatorSettings(
      precision: precision ?? this.precision,
      angleMode: angleMode ?? this.angleMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      soundEffects: soundEffects ?? this.soundEffects,
      historySize: historySize ?? this.historySize,
    );
  }
}
