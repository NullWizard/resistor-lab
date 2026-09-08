import os
import re

file_path = "lib/screens/scan_resistor_screen.dart"
with open(file_path, "r", encoding="utf-8") as f:
    code = f.read()

code = code.replace("import '../services/resistor_scanner_service.dart';", "import '../services/resistor_scanner_service.dart';\nimport '../services/scanner/scanner_coordinator.dart';")

new_process = """
  Future<void> _processImageBytes(Uint8List bytes) async {
    ResistorScanResult result = await ScannerCoordinator.detect(bytes);

    setState(() {
      _capturedImageBytes = bytes;
      _isProcessing = false;
      _lastScanDebugInfo = result.debugInfo;
      if (result.isSuccess) {
        _hasScanError = false;
        _errorMessage = null;
        _detectedBandCount = result.bandCount;
        _selectedBandCount = result.bandCount;
        _band1 = result.band1Index;
        _band2 = result.band2Index;
        _band3 = result.band3Index;
        _band4 = result.band4Index;
        _band5 = result.band5Index ?? 0;
        _band6 = result.band6Index ?? 0;
      } else {
        _hasScanError = true;
        _errorMessage = result.errorMessage ?? "Resistor not detected clearly.";
      }
    });
  }
"""

code = re.sub(r"Future<void> _processImageBytes\(Uint8List bytes\) async \{.*?  \}", new_process, code, flags=re.DOTALL)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(code)

print("Done")
