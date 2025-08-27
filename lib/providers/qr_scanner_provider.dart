import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/model/qresult.dart';

class QrScannerProvider extends ChangeNotifier {
  //bool _isScanning = true;
  bool _torchOn = false;
  bool _usingFrontCamera = false;
  QrResult? _lastResult;
  final List<QrResult> _history = [];

 // bool get isScanning => _isScanning;
  bool get torchOn => _torchOn;
  bool get usingFrontCamera => _usingFrontCamera;
  QrResult? get lastResult => _lastResult;
  List<QrResult> get history => List.unmodifiable(_history);

  // void setScanning(bool value) {
  //   if (_isScanning == value) return;
  //   _isScanning = value;
  //   notifyListeners();
  // }

  void setTorch(bool on) {
    if (_torchOn == on) return;
    _torchOn = on;
    notifyListeners();
  }

  void setCameraFacing(bool front) {
    if (_usingFrontCamera == front) return;
    _usingFrontCamera = front;
    notifyListeners();
  }

  void setResult(String value) {
    final result = QrResult(rawValue: value, scannedAt: DateTime.now());
    _lastResult = result;
    _history.insert(0, result);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
