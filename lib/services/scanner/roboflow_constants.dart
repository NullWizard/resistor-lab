// lib/services/scanner/roboflow_constants.dart

/// Non‑secret configuration for the Roboflow detector.
const String roboflowModelId = 'resistor-and-band-detection/6';
/// Raw confidence floor – detections below this are still kept but may be filtered later.
const double roboflowMinConfidenceFloor = 0.02;
