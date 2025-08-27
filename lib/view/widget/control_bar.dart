import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/controller/qr_scanner_controller.dart';
import 'package:qr_code_scanner/providers/qr_scanner_provider.dart';

class ControlsBar extends StatelessWidget {
  final QrScannerController controller;
  const ControlsBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QrScannerProvider>();
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            onTap: controller.toggleTorch,
            icon: provider.torchOn ? Icons.flash_on : Icons.flash_off,
            label: provider.torchOn ? 'Torch On' : 'Torch Off',
            color: provider.torchOn ? Colors.amber : theme.colorScheme.primary,
          ),
          _ControlButton(
            onTap: controller.switchCamera,
            icon: Icons.cameraswitch,
            label: provider.usingFrontCamera ? 'Front' : 'Back',
            color: theme.colorScheme.primary,
          ),
          _ControlButton(
            onTap: controller.pauseOrResume,
            icon: provider.isScanning ? Icons.pause : Icons.play_arrow,
            label: provider.isScanning ? 'Pause' : 'Resume',
            color: provider.isScanning
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;

  const _ControlButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
