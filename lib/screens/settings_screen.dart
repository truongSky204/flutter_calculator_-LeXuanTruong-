import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calculator_settings.dart';
import '../providers/calculator_provider.dart';
import '../providers/history_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _updateSettings(
      BuildContext context, {
        int? precision,
        AngleMode? angleMode,
        bool? haptic,
        bool? sound,
        int? historySize,
      }) async {
    final calc = context.read<CalculatorProvider>();
    final history = context.read<HistoryProvider>();

    final current = calc.settings;

    final updated = current.copyWith(
      precision: precision,
      angleMode: angleMode,
      hapticFeedback: haptic,
      soundEffects: sound,
      historySize: historySize,
    );

    calc.settings = updated;
    await calc.storage.saveSettings(updated);

    // cập nhật lại history size nếu thay đổi
    await history.setMaxItems(updated.historySize);

    calc.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<CalculatorProvider>();
    final theme = context.watch<ThemeProvider>();
    final history = context.watch<HistoryProvider>();

    final settings = calc.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Theme",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // --- Theme Selection: Light / Dark / System ---
          RadioListTile<ThemeMode>(
            title: const Text("Light"),
            value: ThemeMode.light,
            groupValue: theme.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                theme.setTheme(mode);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("Dark"),
            value: ThemeMode.dark,
            groupValue: theme.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                theme.setTheme(mode);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text("System"),
            value: ThemeMode.system,
            groupValue: theme.themeMode,
            onChanged: (mode) {
              if (mode != null) {
                theme.setTheme(mode);
              }
            },
          ),

          const Divider(height: 24),

          // --- Decimal Precision ---
          const Text(
            "Decimal Precision",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Digits after decimal (2–10)"),
              Text(settings.precision.toString()),
            ],
          ),
          Slider(
            min: 2,
            max: 10,
            divisions: 8,
            value: settings.precision.clamp(2, 10).toDouble(),
            label: settings.precision.toString(),
            onChanged: (v) {
              _updateSettings(context, precision: v.toInt());
            },
          ),

          const Divider(height: 24),

          // --- Angle Mode ---
          const Text(
            "Angle Mode",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text("Degrees (DEG) / Radians (RAD)"),
            subtitle: Text(
              settings.angleMode == AngleMode.degrees
                  ? "Currently: Degrees"
                  : "Currently: Radians",
            ),
            value: settings.angleMode == AngleMode.degrees,
            onChanged: (val) {
              final mode = val ? AngleMode.degrees : AngleMode.radians;
              _updateSettings(context, angleMode: mode);
            },
          ),

          const Divider(height: 24),

          // --- Haptic & Sound ---
          const Text(
            "Feedback",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: const Text("Haptic Feedback"),
            value: settings.hapticFeedback,
            onChanged: (val) {
              _updateSettings(context, haptic: val);
            },
          ),
          SwitchListTile(
            title: const Text("Sound Effects"),
            value: settings.soundEffects,
            onChanged: (val) {
              _updateSettings(context, sound: val);
            },
          ),

          const Divider(height: 24),

          // --- History Size ---
          const Text(
            "History",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: const Text("History Size"),
            subtitle:
            Text("Current: ${settings.historySize} calculations"),
            trailing: DropdownButton<int>(
              value: settings.historySize,
              items: const [
                DropdownMenuItem(
                  value: 25,
                  child: Text("25"),
                ),
                DropdownMenuItem(
                  value: 50,
                  child: Text("50"),
                ),
                DropdownMenuItem(
                  value: 100,
                  child: Text("100"),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  _updateSettings(context, historySize: val);
                }
              },
            ),
          ),
          ListTile(
            title: const Text(
              "Clear All History",
              style: TextStyle(color: Colors.red),
            ),
            subtitle: Text(
              "Current items: ${history.items.length}",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.delete_outline, color: Colors.red),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Clear History"),
                  content: const Text(
                      "Are you sure you want to delete all saved calculations?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        "Clear",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await history.clearAll();
              }
            },
          ),
        ],
      ),
    );
  }
}
