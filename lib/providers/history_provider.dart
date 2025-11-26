import 'package:flutter/material.dart';

import '../models/calculation_history.dart';
import '../services/storage_service.dart';

class HistoryProvider extends ChangeNotifier {
  final StorageService storage;

  List<CalculationHistory> items = [];

  /// Số dòng history tối đa, mặc định 50 – sẽ được set từ Settings
  int maxItems = 50;

  HistoryProvider(this.storage);

  Future<void> load() async {
    items = await storage.loadHistory();
    notifyListeners();
  }

  Future<void> add(CalculationHistory item) async {
    items.insert(0, item);

    if (items.length > maxItems) {
      items = items.sublist(0, maxItems);
    }

    await storage.saveHistory(items);
    notifyListeners();
  }

  Future<void> clearAll() async {
    items.clear();
    await storage.clearHistory();
    notifyListeners();
  }

  /// Đổi kích thước history (25/50/100)
  Future<void> setMaxItems(int value) async {
    maxItems = value;

    if (items.length > maxItems) {
      items = items.sublist(0, maxItems);
      await storage.saveHistory(items);
    }

    notifyListeners();
  }
}
