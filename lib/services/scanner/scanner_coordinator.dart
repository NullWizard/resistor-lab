import 'dart:typed_data';
import '../resistor_scanner_service.dart';
import 'scanner_models.dart';
import 'band_detector.dart';

class ScannerCoordinator {
  static Future<ResistorScanResult> detect(Uint8List imageBytes, {int? expectedBandCount}) async {
    // Detect resistor bands using visual recognition
    final candidate = await BandDetector.detect(imageBytes);

    if (!candidate.success) {
      return ResistorScanResult(
        bandCount: 0,
        band1Index: 0,
        band2Index: 0,
        band3Index: 0,
        band4Index: 0,
        isSuccess: false,
        errorMessage: candidate.errorMessage ?? 'Detection failed. Please check camera focus.',
        debugInfo: ResistorScanDebugInfo(
          detectedBandCount: 0,
          totalCandidatesFound: 0,
          allCandidates: const [],
          selectedCandidates: const [],
          orientationDirection: 'unknown',
          notes: candidate.errorMessage ?? 'Detection failed. Please check camera focus.',
          preprocessingPass: candidate.isResistor ? 'DETECTION_FAILED' : 'NO_RESISTOR_FOUND',
        ),
      );
    }

    // Convert detected bands to UI candidates
    final uiCandidates = candidate.bands.map((b) => ResistorBandCandidate(
      colorCode: _colorToCandidateCode(b.color),
      axisPosition: b.axisPosition,
      confidence: b.confidence,
    )).toList();

    int b1 = 0;
    int b2 = 0;
    int b3 = 0;
    int b4 = 0;
    int? b5;
    int? b6;

    final count = candidate.bandCount;
    final bands = candidate.bands;

    if (count == 4 && bands.length >= 4) {
      b1 = _colorToDigit(bands[0].color);
      b2 = _colorToDigit(bands[1].color);
      b3 = _colorToMultiplier(bands[2].color);
      b4 = _colorToTolerance(bands[3].color);
    } else if (count == 5 && bands.length >= 5) {
      b1 = _colorToDigit(bands[0].color);
      b2 = _colorToDigit(bands[1].color);
      b3 = _colorToDigit(bands[2].color);
      b4 = _colorToMultiplier(bands[3].color);
      b5 = _colorToTolerance(bands[4].color);
    } else if (count == 6 && bands.length >= 6) {
      b1 = _colorToDigit(bands[0].color);
      b2 = _colorToDigit(bands[1].color);
      b3 = _colorToDigit(bands[2].color);
      b4 = _colorToMultiplier(bands[3].color);
      b5 = _colorToTolerance(bands[4].color);
      b6 = _colorToTempCo(bands[5].color);
    } else if (bands.isNotEmpty) {
      b1 = _colorToDigit(bands[0].color);
      if (bands.length > 1) b2 = _colorToDigit(bands[1].color);
      if (bands.length > 2) b3 = _colorToMultiplier(bands[2].color);
      if (bands.length > 3) b4 = _colorToTolerance(bands[3].color);
    }

    return ResistorScanResult(
      bandCount: candidate.bandCount,
      band1Index: b1,
      band2Index: b2,
      band3Index: b3,
      band4Index: b4,
      band5Index: b5,
      band6Index: b6,
      isSuccess: true,
      detectedCandidates: uiCandidates,
      scannerConfidence: candidate.overallConfidence,
      source: 'vision',
      debugInfo: ResistorScanDebugInfo(
        detectedBandCount: candidate.bandCount,
        totalCandidatesFound: candidate.bands.length,
        allCandidates: uiCandidates,
        selectedCandidates: uiCandidates,
        orientationDirection: 'horizontal',
        notes: 'Visual recognition processing succeeded.',
        preprocessingPass: 'VISION',
      ),
    );
  }

  static int _colorToDigit(BandColor c) {
    switch (c) {
      case BandColor.black: return 0;
      case BandColor.brown: return 1;
      case BandColor.red: return 2;
      case BandColor.orange: return 3;
      case BandColor.yellow: return 4;
      case BandColor.green: return 5;
      case BandColor.blue: return 6;
      case BandColor.violet: return 7;
      case BandColor.grey: return 8;
      case BandColor.white: return 9;
      default: return 0;
    }
  }

  static int _colorToMultiplier(BandColor c) {
    switch (c) {
      case BandColor.black: return 0;
      case BandColor.brown: return 1;
      case BandColor.red: return 2;
      case BandColor.orange: return 3;
      case BandColor.yellow: return 4;
      case BandColor.green: return 5;
      case BandColor.blue: return 6;
      case BandColor.violet: return 7;
      case BandColor.grey: return 8;
      case BandColor.white: return 9;
      case BandColor.gold: return 10;
      case BandColor.silver: return 11;
      default: return 0;
    }
  }

  static int _colorToTolerance(BandColor c) {
    switch (c) {
      case BandColor.brown: return 0;
      case BandColor.red: return 1;
      case BandColor.gold: return 2;
      case BandColor.silver: return 3;
      case BandColor.green: return 4;
      case BandColor.blue: return 5;
      case BandColor.violet: return 6;
      case BandColor.grey: return 7;
      default: return 2; // default Gold
    }
  }

  static int _colorToTempCo(BandColor c) {
    switch (c) {
      case BandColor.brown: return 0;
      case BandColor.red: return 1;
      case BandColor.orange: return 2;
      case BandColor.yellow: return 3;
      case BandColor.blue: return 4;
      case BandColor.violet: return 5;
      default: return 0;
    }
  }

  static int _colorToCandidateCode(BandColor c) {
    switch (c) {
      case BandColor.black: return 0;
      case BandColor.brown: return 1;
      case BandColor.red: return 2;
      case BandColor.orange: return 3;
      case BandColor.yellow: return 4;
      case BandColor.green: return 5;
      case BandColor.blue: return 6;
      case BandColor.violet: return 7;
      case BandColor.grey: return 8;
      case BandColor.white: return 9;
      case BandColor.gold: return 10;
      case BandColor.silver: return 11;
      default: return 0;
    }
  }
}

