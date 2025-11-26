import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            onPressed: () => history.clearAll(),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: history.items.length,
        separatorBuilder: (_, __) =>
        const Divider(height: 1, thickness: 0.5),
        itemBuilder: (_, i) {
          final h = history.items[i];
          return ListTile(
            title: Text(h.expression),
            subtitle: Text(h.result),
            trailing: Text(
              "${h.timestamp.hour.toString().padLeft(2, '0')}:${h.timestamp.minute.toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
