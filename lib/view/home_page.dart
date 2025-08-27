import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/controller/qr_scanner_controller.dart';
import 'package:qr_code_scanner/view/widget/control_bar.dart';
import 'package:qr_code_scanner/view/widget/scanner_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/qr_scanner_provider.dart';
import 'history_view.dart';

class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  late final QrScannerController _controller;

  @override
  void initState() {
    super.initState();
    final provider = context.read<QrScannerProvider>();
    _controller = QrScannerController(provider: provider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QrScannerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed:
                () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const HistoryView())),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller.mobileScannerController,
                      onDetect: _controller.handleDetection,
                    ),
                    // Simple overlay
                    // IgnorePointer(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(
                    //         color: Theme.of(
                    //           context,
                    //         ).colorScheme.primary.withOpacity(0.6),
                    //         width: 2,
                    //       ),
                    //       borderRadius: BorderRadius.circular(16),
                    //     ),
                    //   ),
                    // ),
                    ScannerOverlay(overlaySize: 250,)
                  ],
                ),
              ),
            ),
          ),
          if (provider.lastResult != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: InkWell(
                onTap: () async {
                  //log(provider.lastResult!.rawValue)  ;
                  final url = Uri.tryParse(provider.lastResult!.rawValue);
                  log(url.toString());

                  if (url != null) {
                    try {
                      await launchUrl(
                        url,
                        mode:
                            LaunchMode
                                .externalApplication, // ✅ opens default browser
                      );
                    } catch (e) {
                      log(e.toString());
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid or unsupported link'),
                      ),
                    );
                  }
                },
                child: _ResultTile(text: provider.lastResult!.rawValue),
              ),
            ),
          const SizedBox(height: 8),
          ControlsBar(controller: _controller),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final String text;
  const _ResultTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        title: const Text('Last result'),
        subtitle: Text(text, maxLines: 3, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          tooltip: 'Copy',
          icon: const Icon(Icons.copy_all),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            }
          },
        ),
      ),
    );
  }
}
