// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/providers/qr_scanner_provider.dart';
import 'package:qr_code_scanner/view/home_page.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => QrScannerProvider(),
      child: MaterialApp(
        home: QrScannerView(),

      ),
    ),
  );
}