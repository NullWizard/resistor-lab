import 'package:flutter/material.dart';

enum BandColor {
  black, brown, red, orange, yellow, green, blue, violet, grey, white, gold, silver, none
}

class DetectedBand {
  final BandColor color;
  final double axisPosition; // Normalized position along resistor axis (0.0 to 1.0)
  final double startPosition;
  final double endPosition;
  final double width;
  final double confidence;
  final int agreementCount;
  final int totalDetectors;
  final bool needsConfirmation;

  const DetectedBand({
    required this.color,
    required this.axisPosition,
    required this.startPosition,
    required this.endPosition,
    required this.width,
    required this.confidence,
    this.agreementCount = 1,
    this.totalDetectors = 1,
    this.needsConfirmation = false,
  });

  String get colorName {
    final str = color.toString().split('.').last;
    return str[0].toUpperCase() + str.substring(1);
  }

  DetectedBand copyWith({
    BandColor? color,
    double? axisPosition,
    double? startPosition,
    double? endPosition,
    double? width,
    double? confidence,
    int? agreementCount,
    int? totalDetectors,
    bool? needsConfirmation,
  }) {
    return DetectedBand(
      color: color ?? this.color,
      axisPosition: axisPosition ?? this.axisPosition,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      width: width ?? this.width,
      confidence: confidence ?? this.confidence,
      agreementCount: agreementCount ?? this.agreementCount,
      totalDetectors: totalDetectors ?? this.totalDetectors,
      needsConfirmation: needsConfirmation ?? this.needsConfirmation,
    );
  }
}

class RoboflowDetection {
  final String className; // e.g. "brown", "resistor", "gold"
  final double confidence; // 0..1 raw model confidence
  final Rect bbox; // left, top, width, height in image pixels
  const RoboflowDetection({required this.className, required this.confidence, required this.bbox});
}


class RecognitionCandidate {
  final bool success;
  final bool isResistor;
  final int bandCount;
  final List<DetectedBand> bands;
  final double overallConfidence;
  final String source;
  final String? errorMessage;
  final Map<String, double>? rawSourceConfidences;
  final double detectorConfidence;

  const RecognitionCandidate({
    required this.success,
    this.isResistor = true,
    this.bandCount = 0,
    this.bands = const [],
    this.overallConfidence = 0.0,
    required this.source,
    this.errorMessage,
    this.rawSourceConfidences,
    this.detectorConfidence = 1.0,
  });

  RecognitionCandidate copyWith({
    bool? success,
    bool? isResistor,
    int? bandCount,
    List<DetectedBand>? bands,
    double? overallConfidence,
    String? source,
    String? errorMessage,
    Map<String, double>? rawSourceConfidences,
    double? detectorConfidence,
  }) {
    return RecognitionCandidate(
      success: success ?? this.success,
      isResistor: isResistor ?? this.isResistor,
      bandCount: bandCount ?? this.bandCount,
      bands: bands ?? this.bands,
      overallConfidence: overallConfidence ?? this.overallConfidence,
      source: source ?? this.source,
      errorMessage: errorMessage ?? this.errorMessage,
      rawSourceConfidences: rawSourceConfidences ?? this.rawSourceConfidences,
      detectorConfidence: detectorConfidence ?? this.detectorConfidence,
    );
  }
}

class ProcessedResult {
  final bool success;
  final int bandCount;
  final List<DetectedBand> bands;
  final double overallConfidence;
  final String orientationDirection;
  final String? errorMessage;

  const ProcessedResult({
    required this.success,
    this.bandCount = 0,
    this.bands = const [],
    this.overallConfidence = 0.0,
    this.orientationDirection = 'unknown',
    this.errorMessage,
  });
}

class ValidationRecord {
  final int expectedBandCount;
  final List<BandColor> expectedColors;
  final bool expectedReversed;
  
  const ValidationRecord({
    required this.expectedBandCount,
    required this.expectedColors,
    this.expectedReversed = false,
  });
}
