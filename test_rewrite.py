import os

file_path = "test/widget_test.dart"
with open(file_path, "r", encoding="utf-8") as f:
    code = f.read()

# Replace ResistorScannerService.detectColorsFromImage with CenterlineDetector.detect
code = code.replace("ResistorScannerService.detectColorsFromImage", "CenterlineDetector.detect")
code = code.replace("import 'package:resistor_lab/services/resistor_scanner_service.dart';", "import 'package:resistor_lab/services/resistor_scanner_service.dart';\nimport 'package:resistor_lab/services/scanner/centerline_detector.dart';\nimport 'package:resistor_lab/services/scanner/paper_cv_detector.dart';\nimport 'package:resistor_lab/services/scanner/ensemble_engine.dart';\nimport 'package:resistor_lab/services/scanner/scanner_models.dart';")

# We have to change the return type handling since detect is async and returns RecognitionCandidate instead of ResistorScanResult
code = code.replace("final result = CenterlineDetector.detect(imgBytes, bandCount: 4);", "final result = await CenterlineDetector.detect(imgBytes);")
code = code.replace("final result = CenterlineDetector.detect(imgBytes, bandCount: 5);", "final result = await CenterlineDetector.detect(imgBytes);")
code = code.replace("final result = CenterlineDetector.detect(imgBytes, bandCount: 6);", "final result = await CenterlineDetector.detect(imgBytes);")

# We need to change expect(result.isSuccess, true) and checking result.detectedCandidates to result.bands
code = code.replace("result.isSuccess", "result.success")
code = code.replace("result.detectedCandidates", "result.bands")
code = code.replace("c.colorCode", "c.color.index") # This might not map correctly since BandColor.black is 0, brown 1, etc which matches exactly!
code = code.replace("testWidgets", "testWidgets") # Just keeping testWidgets

with open(file_path, "w", encoding="utf-8") as f:
    f.write(code)

print("Tests replaced")
