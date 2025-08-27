import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/qr_scanner_provider.dart';


/// Controller contains imperative interactions with the camera/scanner.
class QrScannerController {
final MobileScannerController mobileScannerController = MobileScannerController();
final QrScannerProvider provider;


QrScannerController({required this.provider});


 Future<void> toggleTorch() async {
  mobileScannerController.toggleTorch();
    // TorchState is a Stream<TorchState>, so we can check the latest value
    //final currentState = await torch.torchState.first;
final torchState=provider.torchOn;
   
      provider.setTorch(!torchState);
    
  }


Future<void> switchCamera() async {
await mobileScannerController.switchCamera();
final facing =  mobileScannerController.facing;
provider.setCameraFacing(facing == CameraFacing.front);
}


Future<void> pauseOrResume() async {
if (provider.isScanning) {
await mobileScannerController.stop();
provider.setScanning(false);
} else {
await mobileScannerController.start();
provider.setScanning(true);
}
}


void handleDetection(BarcodeCapture capture) {
// Only take the first barcode in the frame for simplicity
final first = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
final raw = first?.rawValue;
if (raw != null && raw.isNotEmpty) {
provider.setResult(raw);
// Optional: pause after first detection to avoid repeated triggers
mobileScannerController.stop();
provider.setScanning(false);
}
}


void dispose() {
mobileScannerController.dispose();
}
}