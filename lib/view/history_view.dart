import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qr_scanner_provider.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QrScannerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            onPressed: provider.history.isEmpty ? null : provider.clearHistory,
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear history',
          ),
        ],
      ),
      body:
          provider.history.isEmpty
              ? const Center(child: Text('No scans yet'))
              : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: provider.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = provider.history[index];
                  return Material(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      title: Text(
                        item.rawValue,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(item.scannedAt.toLocal().toString()),
                    ),
                  );
                },
              ),
    );
  }
}
