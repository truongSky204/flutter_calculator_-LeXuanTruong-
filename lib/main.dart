import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/calculator_screen.dart';
import 'providers/calculator_provider.dart';
import 'providers/history_provider.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storage)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(storage)..load(),
        ),
        ChangeNotifierProxyProvider<HistoryProvider, CalculatorProvider>(
          create: (context) => CalculatorProvider(
            storage: storage,
            historyProvider: HistoryProvider(storage),
          ),
          update: (context, history, previous) =>
              CalculatorProvider(storage: storage, historyProvider: history),
        ),
      ],
      child: const CalculatorApp(),
    ),
  );
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.themeMode,
      home: const CalculatorScreen(),
    );
  }
}
