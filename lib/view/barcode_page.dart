import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class QrGeneratorPage extends StatefulWidget {
  const QrGeneratorPage({super.key});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  
  String _inputText = "";
  String _title = "";
  String _subtitle = "";
  File? _selectedImage;
  final GlobalKey _globalKey = GlobalKey();
  
  // Customization options
  Color _backgroundColor = Colors.white;
  Color _qrColor = Colors.black;
  Color _frameColor = Colors.blue;
  String _selectedTemplate = 'professional';
  bool _showLogo = true;
  bool _showBorder = true;
  double _qrSize = 200.0;

  final ImagePicker _picker = ImagePicker();

Future<void> _pickImage() async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Select Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _getImageFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _getImageFromSource(ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}

Future<void> _getImageFromSource(ImageSource source) async {
  try {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to pick image: $e")),
    );
  }
}


  Future<void> _saveQr() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final saveImage = await SaverGallery.saveImage(
        pngBytes,
        quality: 100,
        fileName: "custom_qr_${DateTime.now().millisecondsSinceEpoch}.png",
        skipIfExists: false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saveImage.isSuccess == true ? "QR Code saved to Gallery!" : "Failed to save",
          ),
          backgroundColor: saveImage.isSuccess == true ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _buildQrDisplay() {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: _showBorder ? Border.all(color: _frameColor, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo/Image section
            if (_selectedImage != null && _showLogo) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Title
            if (_title.isNotEmpty) ...[
              Text(
                _title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _frameColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            
            // Subtitle
            if (_subtitle.isNotEmpty) ...[
              Text(
                _subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            
            // QR Code with decorative frame
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _frameColor.withOpacity(0.3), width: 1),
              ),
              child: BarcodeWidget(
                data: _inputText,
                barcode: Barcode.qrCode(),
                width: _qrSize,
                height: _qrSize,
                color: _qrColor,
                drawText: false,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Footer text
            Text(
              "Scan to access",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            
            // Template-specific decorations
            if (_selectedTemplate == 'gift') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.favorite, color: Colors.pink[300], size: 20),
                  Icon(Icons.card_giftcard, color: Colors.pink[300], size: 20),
                  Icon(Icons.favorite, color: Colors.pink[300], size: 20),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom QR Generator"),
        centerTitle: true,
        backgroundColor: _frameColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Content",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dataController,
                      decoration: const InputDecoration(
                        labelText: "QR Data (URL, Text, etc.)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _inputText = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Title (Optional)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _title = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: "Subtitle (Optional)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subtitles),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _subtitle = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Customization Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customization",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Template Selection
                    const Text("Template:", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("Professional"),
                          selected: _selectedTemplate == 'professional',
                          onSelected: (selected) {
                            setState(() {
                              _selectedTemplate = 'professional';
                              _frameColor = Colors.blue;
                              _backgroundColor = Colors.white;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text("Gift"),
                          selected: _selectedTemplate == 'gift',
                          onSelected: (selected) {
                            setState(() {
                              _selectedTemplate = 'gift';
                              _frameColor = Colors.pink;
                              _backgroundColor = Colors.pink[50]!;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text("Business"),
                          selected: _selectedTemplate == 'business',
                          onSelected: (selected) {
                            setState(() {
                              _selectedTemplate = 'business';
                              _frameColor = Colors.teal;
                              _backgroundColor = Colors.grey[50]!;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Image Selection
                    Row(
                      children: [
                        Expanded(
                          child: Text(_selectedImage != null 
                              ? "Image selected" 
                              : "No image selected"),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image),
                          label: const Text("Add Logo"),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // QR Size Slider
                    Text("QR Size: ${_qrSize.round()}px"),
                    Slider(
                      value: _qrSize,
                      min: 150,
                      max: 300,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _qrSize = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Toggle Options
                    SwitchListTile(
                      title: const Text("Show Logo"),
                      value: _showLogo,
                      onChanged: (value) {
                        setState(() {
                          _showLogo = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text("Show Border"),
                      value: _showBorder,
                      onChanged: (value) {
                        setState(() {
                          _showBorder = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // QR Code Preview
            if (_inputText.isNotEmpty) ...[
              const Center(
                child: Text(
                  "Preview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: _buildQrDisplay()),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveQr,
                  icon: const Icon(Icons.download),
                  label: const Text("Download QR Code"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _frameColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "Enter QR data above to generate your custom QR code",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
