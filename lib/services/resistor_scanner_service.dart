import 'package:flutter/material.dart';

/// Data structure for a recognized resistor color.
class ResistorBandInfo {
  final String name;
  final int value;
  final double multiplier;
  final double? tolerance;
  final Color color;
  final int refR;
  final int refG;
  final int refB;

  const ResistorBandInfo({
    required this.name,
    required this.value,
    required this.multiplier,
    this.tolerance,
    required this.color,
    required this.refR,
    required this.refG,
    required this.refB,
  });
}

/// Calculated values based on 4, 5, or 6 bands.
class ResistorCalculationResult {
  final double nominalOhms;
  final String readableNominal;
  final double tolerancePercent;
  final String toleranceLabel;
  final double minOhms;
  final double maxOhms;
  final String readableMin;
  final String readableMax;
  final int? tempCoPpm;
  final String? tempCoLabel;

  const ResistorCalculationResult({
    required this.nominalOhms,
    required this.readableNominal,
    required this.tolerancePercent,
    required this.toleranceLabel,
    required this.minOhms,
    required this.maxOhms,
    required this.readableMin,
    required this.readableMax,
    this.tempCoPpm,
    this.tempCoLabel,
  });
}

/// Result of scanning an image.
class ResistorScanResult {
  final int bandCount;
  final int band1Index;
  final int band2Index;
  final int band3Index;
  final int band4Index;
  final int? band5Index;
  final int? band6Index;
  final bool isSuccess;
  final String? errorMessage;
  final List<ResistorBandCandidate> detectedCandidates;
  final ResistorScanDebugInfo? debugInfo;
  final double scannerConfidence;
  final String source;

  const ResistorScanResult({
    this.bandCount = 4,
    required this.band1Index,
    required this.band2Index,
    required this.band3Index,
    required this.band4Index,
    this.band5Index,
    this.band6Index,
    required this.isSuccess,
    this.errorMessage,
    this.detectedCandidates = const [],
    this.debugInfo,
    this.scannerConfidence = 0.0,
    this.source = 'roboflow',
  });

  String get band1Name => ResistorScannerService.digitColors[band1Index].name;
  String get band2Name => ResistorScannerService.digitColors[band2Index].name;
  String get band3Name => bandCount == 4
      ? ResistorScannerService.multiplierColors[band3Index].name
      : ResistorScannerService.digitColors[band3Index].name;
  String get band4Name => bandCount == 4
      ? ResistorScannerService.toleranceColors[band4Index].name
      : ResistorScannerService.multiplierColors[band4Index].name;
  String? get band5Name => (band5Index != null &&
          band5Index! >= 0 &&
          band5Index! < ResistorScannerService.toleranceColors.length)
      ? ResistorScannerService.toleranceColors[band5Index!].name
      : null;
  String? get band6Name => (band6Index != null &&
          band6Index! >= 0 &&
          band6Index! < ResistorScannerService.tempCoColors.length)
      ? ResistorScannerService.tempCoColors[band6Index!].name
      : null;

  ResistorScanResult copyWith({
    int? bandCount,
    int? band1Index,
    int? band2Index,
    int? band3Index,
    int? band4Index,
    int? band5Index,
    int? band6Index,
    bool? isSuccess,
    String? errorMessage,
    List<ResistorBandCandidate>? detectedCandidates,
    ResistorScanDebugInfo? debugInfo,
    double? scannerConfidence,
    String? source,
  }) {
    return ResistorScanResult(
      bandCount: bandCount ?? this.bandCount,
      band1Index: band1Index ?? this.band1Index,
      band2Index: band2Index ?? this.band2Index,
      band3Index: band3Index ?? this.band3Index,
      band4Index: band4Index ?? this.band4Index,
      band5Index: band5Index ?? this.band5Index,
      band6Index: band6Index ?? this.band6Index,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      detectedCandidates: detectedCandidates ?? this.detectedCandidates,
      debugInfo: debugInfo ?? this.debugInfo,
      scannerConfidence: scannerConfidence ?? this.scannerConfidence,
      source: source ?? this.source,
    );
  }
}

/// Developer diagnostic data captured during scanning.
class ResistorScanDebugInfo {
  final int detectedBandCount;
  final int totalCandidatesFound;
  final List<ResistorBandCandidate> allCandidates;
  final List<ResistorBandCandidate> selectedCandidates;
  final String orientationDirection;
  final String preprocessingPass;
  final String notes;

  const ResistorScanDebugInfo({
    required this.detectedBandCount,
    required this.totalCandidatesFound,
    required this.allCandidates,
    required this.selectedCandidates,
    required this.orientationDirection,
    this.preprocessingPass = 'raw',
    this.notes = '',
  });

  @override
  String toString() =>
      'ResistorScanDebugInfo(pass: $preprocessingPass, detected: $detectedBandCount, found: $totalCandidatesFound, selected: ${selectedCandidates.length}, orientation: $orientationDirection)';

  ResistorScanDebugInfo copyWith({
    int? detectedBandCount,
    int? totalCandidatesFound,
    List<ResistorBandCandidate>? allCandidates,
    List<ResistorBandCandidate>? selectedCandidates,
    String? orientationDirection,
    String? preprocessingPass,
    String? notes,
  }) {
    return ResistorScanDebugInfo(
      detectedBandCount: detectedBandCount ?? this.detectedBandCount,
      totalCandidatesFound: totalCandidatesFound ?? this.totalCandidatesFound,
      allCandidates: allCandidates ?? this.allCandidates,
      selectedCandidates: selectedCandidates ?? this.selectedCandidates,
      orientationDirection: orientationDirection ?? this.orientationDirection,
      preprocessingPass: preprocessingPass ?? this.preprocessingPass,
      notes: notes ?? this.notes,
    );
  }
}

/// Represents a candidate resistor color band detected along the physical axis.
class ResistorBandCandidate {
  final int colorCode; // 0..9 for standard digits, 10 for Gold, 11 for Silver
  final double axisPosition; // Centroid along the resistor's physical axis (X coordinate)
  final int pixelCount;
  final int width;
  final int height;
  final double confidence;
  final int minX;
  final int maxX;
  
  

  const ResistorBandCandidate({
    required this.colorCode,
    required this.axisPosition,
    this.pixelCount = 100,
    this.width = 10,
    this.height = 30,
    this.confidence = 1.0,
    this.minX = 0,
    this.maxX = 0,
    
    
  });

  String get colorName {
    if (colorCode >= 0 && colorCode <= 9) {
      return ResistorScannerService.digitColors[colorCode].name;
    } else if (colorCode == 10) {
      return 'Gold';
    } else if (colorCode == 11) {
      return 'Silver';
    }
    return 'Unknown';
  }

  @override
  String toString() =>
      '$colorName@${axisPosition.toStringAsFixed(1)} (w:$width, h:$height, conf:${confidence.toStringAsFixed(2)})';
}





/// Service that handles color matching and calculation for resistors.
class ResistorScannerService {
  // Standard Digit Colors (0-9)
  static const List<ResistorBandInfo> digitColors = [
    ResistorBandInfo(name: 'Black', value: 0, multiplier: 1, color: Color(0xFF212121), refR: 30, refG: 30, refB: 30),
    ResistorBandInfo(name: 'Brown', value: 1, multiplier: 10, tolerance: 1.0, color: Color(0xFF6D4C41), refR: 109, refG: 76, refB: 65),
    ResistorBandInfo(name: 'Red', value: 2, multiplier: 100, tolerance: 2.0, color: Color(0xFFD32F2F), refR: 211, refG: 47, refB: 47),
    ResistorBandInfo(name: 'Orange', value: 3, multiplier: 1000, color: Color(0xFFF57C00), refR: 245, refG: 124, refB: 0),
    ResistorBandInfo(name: 'Yellow', value: 4, multiplier: 10000, color: Color(0xFFFBC02D), refR: 251, refG: 192, refB: 45),
    ResistorBandInfo(name: 'Green', value: 5, multiplier: 100000, color: Color(0xFF388E3C), refR: 56, refG: 142, refB: 60),
    ResistorBandInfo(name: 'Blue', value: 6, multiplier: 1000000, color: Color(0xFF1976D2), refR: 25, refG: 118, refB: 210),
    ResistorBandInfo(name: 'Violet', value: 7, multiplier: 10000000, color: Color(0xFF7B1FA2), refR: 123, refG: 31, refB: 162),
    ResistorBandInfo(name: 'Grey', value: 8, multiplier: 100000000, color: Color(0xFF757575), refR: 117, refG: 117, refB: 117),
    ResistorBandInfo(name: 'White', value: 9, multiplier: 1000000000, color: Color(0xFFFFFFFF), refR: 240, refG: 240, refB: 240),
  ];

  // Standard Multiplier Colors
  static const List<ResistorBandInfo> multiplierColors = [
    ResistorBandInfo(name: 'Black', value: 0, multiplier: 1, color: Color(0xFF212121), refR: 30, refG: 30, refB: 30),
    ResistorBandInfo(name: 'Brown', value: 1, multiplier: 10, color: Color(0xFF6D4C41), refR: 109, refG: 76, refB: 65),
    ResistorBandInfo(name: 'Red', value: 2, multiplier: 100, color: Color(0xFFD32F2F), refR: 211, refG: 47, refB: 47),
    ResistorBandInfo(name: 'Orange', value: 3, multiplier: 1000, color: Color(0xFFF57C00), refR: 245, refG: 124, refB: 0),
    ResistorBandInfo(name: 'Yellow', value: 4, multiplier: 10000, color: Color(0xFFFBC02D), refR: 251, refG: 192, refB: 45),
    ResistorBandInfo(name: 'Green', value: 5, multiplier: 100000, color: Color(0xFF388E3C), refR: 56, refG: 142, refB: 60),
    ResistorBandInfo(name: 'Blue', value: 6, multiplier: 1000000, color: Color(0xFF1976D2), refR: 25, refG: 118, refB: 210),
    ResistorBandInfo(name: 'Violet', value: 7, multiplier: 10000000, color: Color(0xFF7B1FA2), refR: 123, refG: 31, refB: 162),
    ResistorBandInfo(name: 'Grey', value: 8, multiplier: 100000000, color: Color(0xFF757575), refR: 117, refG: 117, refB: 117),
    ResistorBandInfo(name: 'White', value: 9, multiplier: 1000000000, color: Color(0xFFFFFFFF), refR: 240, refG: 240, refB: 240),
    ResistorBandInfo(name: 'Gold', value: -1, multiplier: 0.1, color: Color(0xFFFFD700), refR: 212, refG: 175, refB: 55),
    ResistorBandInfo(name: 'Silver', value: -2, multiplier: 0.01, color: Color(0xFFC0C0C0), refR: 192, refG: 192, refB: 192),
  ];

  // Standard Tolerance Colors
  static const List<ResistorBandInfo> toleranceColors = [
    ResistorBandInfo(name: 'Brown', value: 1, multiplier: 10, tolerance: 1.0, color: Color(0xFF6D4C41), refR: 109, refG: 76, refB: 65),
    ResistorBandInfo(name: 'Red', value: 2, multiplier: 100, tolerance: 2.0, color: Color(0xFFD32F2F), refR: 211, refG: 47, refB: 47),
    ResistorBandInfo(name: 'Gold', value: -1, multiplier: 0.1, tolerance: 5.0, color: Color(0xFFFFD700), refR: 212, refG: 175, refB: 55),
    ResistorBandInfo(name: 'Silver', value: -2, multiplier: 0.01, tolerance: 10.0, color: Color(0xFFC0C0C0), refR: 192, refG: 192, refB: 192),
    ResistorBandInfo(name: 'Green', value: 5, multiplier: 100000, tolerance: 0.5, color: Color(0xFF388E3C), refR: 56, refG: 142, refB: 60),
    ResistorBandInfo(name: 'Blue', value: 6, multiplier: 1000000, tolerance: 0.25, color: Color(0xFF1976D2), refR: 25, refG: 118, refB: 210),
    ResistorBandInfo(name: 'Violet', value: 7, multiplier: 10000000, tolerance: 0.1, color: Color(0xFF7B1FA2), refR: 123, refG: 31, refB: 162),
    ResistorBandInfo(name: 'Grey', value: 8, multiplier: 100000000, tolerance: 0.05, color: Color(0xFF757575), refR: 117, refG: 117, refB: 117),
  ];

  // Standard Temperature Coefficient Colors (ppm/K) for 6-Band Resistors
  static const List<ResistorBandInfo> tempCoColors = [
    ResistorBandInfo(name: 'Brown', value: 100, multiplier: 0, color: Color(0xFF6D4C41), refR: 109, refG: 76, refB: 65),
    ResistorBandInfo(name: 'Red', value: 50, multiplier: 0, color: Color(0xFFD32F2F), refR: 211, refG: 47, refB: 47),
    ResistorBandInfo(name: 'Orange', value: 15, multiplier: 0, color: Color(0xFFF57C00), refR: 245, refG: 124, refB: 0),
    ResistorBandInfo(name: 'Yellow', value: 25, multiplier: 0, color: Color(0xFFFBC02D), refR: 251, refG: 192, refB: 45),
    ResistorBandInfo(name: 'Blue', value: 10, multiplier: 0, color: Color(0xFF1976D2), refR: 25, refG: 118, refB: 210),
    ResistorBandInfo(name: 'Violet', value: 5, multiplier: 0, color: Color(0xFF7B1FA2), refR: 123, refG: 31, refB: 162),
  ];

  /// Calculates nominal resistance, tolerance bounds, and optional temperature coefficient.
  /// Supports 4-band, 5-band, and 6-band resistors.
  static ResistorCalculationResult calculate({
    int bandCount = 4,
    required int band1Index,
    required int band2Index,
    required int band3Index,
    required int band4Index,
    int band5Index = 0,
    int band6Index = 0,
  }) {
    double nominalOhms;
    double tolPercent;
    int? tempCo;
    String? tempCoStr;

    final b1 = digitColors[band1Index.clamp(0, digitColors.length - 1)];
    final b2 = digitColors[band2Index.clamp(0, digitColors.length - 1)];

    if (bandCount == 4) {
      // Band 1 = 1st digit, Band 2 = 2nd digit, Band 3 = multiplier, Band 4 = tolerance
      final mult = multiplierColors[band3Index.clamp(0, multiplierColors.length - 1)];
      final tol = toleranceColors[band4Index.clamp(0, toleranceColors.length - 1)];
      nominalOhms = (b1.value * 10 + b2.value) * mult.multiplier;
      tolPercent = tol.tolerance ?? 5.0;
    } else {
      // Band 1 = 1st digit, Band 2 = 2nd digit, Band 3 = 3rd digit, Band 4 = multiplier, Band 5 = tolerance
      final b3 = digitColors[band3Index.clamp(0, digitColors.length - 1)];
      final mult = multiplierColors[band4Index.clamp(0, multiplierColors.length - 1)];
      final tol = toleranceColors[band5Index.clamp(0, toleranceColors.length - 1)];
      nominalOhms = (b1.value * 100 + b2.value * 10 + b3.value) * mult.multiplier;
      tolPercent = tol.tolerance ?? 1.0;

      if (bandCount == 6) {
        final tc = tempCoColors[band6Index.clamp(0, tempCoColors.length - 1)];
        tempCo = tc.value;
        tempCoStr = '${tc.value} ppm/K';
      }
    }

    final double minOhms = nominalOhms * (1.0 - (tolPercent / 100.0));
    final double maxOhms = nominalOhms * (1.0 + (tolPercent / 100.0));

    return ResistorCalculationResult(
      nominalOhms: nominalOhms,
      readableNominal: formatResistance(nominalOhms),
      tolerancePercent: tolPercent,
      toleranceLabel: '±${_formatNumber(tolPercent)}%',
      minOhms: minOhms,
      maxOhms: maxOhms,
      readableMin: formatResistance(minOhms),
      readableMax: formatResistance(maxOhms),
      tempCoPpm: tempCo,
      tempCoLabel: tempCoStr,
    );
  }

  /// Formats resistance in ohms to engineering units (Ω, kΩ, MΩ, GΩ).
  static String formatResistance(double ohms) {
    if (ohms >= 1e9) {
      return '${_formatNumber(ohms / 1e9)} GΩ';
    } else if (ohms >= 1e6) {
      return '${_formatNumber(ohms / 1e6)} MΩ';
    } else if (ohms >= 1e3) {
      return '${_formatNumber(ohms / 1e3)} kΩ';
    } else {
      return '${_formatNumber(ohms)} Ω';
    }
  }

  static String _formatNumber(double val) {
    String s = val.toStringAsFixed(3);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  
}
