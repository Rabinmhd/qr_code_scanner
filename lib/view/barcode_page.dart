import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:saver_gallery/saver_gallery.dart';

class QrGeneratorPage extends StatefulWidget {
  const QrGeneratorPage({super.key});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  String _inputText = "";
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _saveQr() async {
    try {
      // Convert widget to image
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to gallery
      final saveImage = await SaverGallery.saveImage(
        pngBytes,
        quality: 100,
        fileName: "qr_${DateTime.now().millisecondsSinceEpoch}.png",
        skipIfExists: false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saveImage.isSuccess == true ? "Saved to Gallery!" : "Failed to save",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Generator"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField for input
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter Link or Text",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _inputText = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Display QR Code
            if (_inputText.isNotEmpty) ...[
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      color: Colors.white, // 🔹 White background frame
                      padding: const EdgeInsets.all(16), // optional margin inside frame
                      child: BarcodeWidget(
                        data: _inputText,
                        barcode: Barcode.qrCode(),
                        width: 220,
                        height: 220,
                        drawText: false,
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saveQr,
                icon: const Icon(Icons.download),
                label: const Text("Download QR Code"),
              ),
            ] else
              const Text(
                "Enter text above to generate QR Code",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
