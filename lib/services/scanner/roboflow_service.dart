import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'roboflow_constants.dart';
import 'scanner_models.dart';

/// Service that communicates with the Roboflow serverless API.
/// It sends an image and parses the JSON response into a list of
/// [RoboflowDetection] objects.
class RoboflowService {
  // Private constructor for singleton pattern.
  RoboflowService._();
  static final RoboflowService instance = RoboflowService._();

  /// Sends the given image bytes to Roboflow and returns raw [RoboflowDetection] objects.
  Future<List<RoboflowDetection>> detectRaw(Uint8List imageBytes) async {
    final apiKey = dotenv.env['ROBOFLOW_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Roboflow API key not found in .env');
    }

    final uri = Uri.parse('https://serverless.roboflow.com/$roboflowModelId?confidence=0.01');
    final base64Image = base64Encode(imageBytes);

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: base64Image,
    );

    bool isJsonReceived = false;
    List<RoboflowDetection> detections = [];

    if (response.statusCode == 200) {
      try {
        detections = _parseDetections(response.body);
        isJsonReceived = true;
      } catch (_) {
        isJsonReceived = false;
      }
    }

    if (kDebugMode) {
      debugPrint('[Roboflow Diagnostic] Status: ${response.statusCode}');
      debugPrint('[Roboflow Diagnostic] Endpoint: ${uri.path}');
      debugPrint('[Roboflow Diagnostic] JSON received: $isJsonReceived');
      debugPrint('[Roboflow Diagnostic] Detections parsed: ${detections.length}');
    }

    if (response.statusCode != 200) {
      throw Exception('Roboflow request failed: ${response.statusCode} - ${response.body}');
    }

    return detections;
  }

  /// Sends the given image bytes to Roboflow and returns a [RecognitionCandidate].
  Future<RecognitionCandidate> detect(Uint8List imageBytes) async {
    final detections = await detectRaw(imageBytes);
    final hasResistor = detections.any((d) => d.className.toLowerCase() == 'resistor');
    return RecognitionCandidate(
      success: hasResistor,
      source: 'roboflow',
      overallConfidence: detections.isNotEmpty
          ? detections.map((d) => d.confidence).reduce((a, b) => a + b) / detections.length
          : 0.0,
    );
  }

  /// Public wrapper for unit‑testing the JSON parser.
  List<RoboflowDetection> parseDetections(String jsonString) => _parseDetections(jsonString);

  // -----------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------
  List<RoboflowDetection> _parseDetections(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
    final List<dynamic> predictions = data['predictions'] as List<dynamic>? ?? [];
    return predictions.map((dynamic item) {
      final map = item as Map<String, dynamic>;
      var className = map['class'] as String? ?? '';
      // Map "purple" to "violet" per colour‑code rules.
      if (className.toLowerCase() == 'purple') {
        className = 'violet';
      }
      final confidence = (map['confidence'] as num?)?.toDouble() ?? 0.0;
      double left = 0.0;
      double top = 0.0;
      double width = 0.0;
      double height = 0.0;
      if (map.containsKey('bbox') && map['bbox'] is Map) {
        final bboxMap = map['bbox'] as Map<String, dynamic>;
        left = (bboxMap['x'] as num?)?.toDouble() ?? 0.0;
        top = (bboxMap['y'] as num?)?.toDouble() ?? 0.0;
        width = (bboxMap['width'] as num?)?.toDouble() ?? 0.0;
        height = (bboxMap['height'] as num?)?.toDouble() ?? 0.0;
      } else {
        // Direct Roboflow predictions format (x, y are center)
        final cx = (map['x'] as num?)?.toDouble() ?? 0.0;
        final cy = (map['y'] as num?)?.toDouble() ?? 0.0;
        width = (map['width'] as num?)?.toDouble() ?? 0.0;
        height = (map['height'] as num?)?.toDouble() ?? 0.0;
        left = cx - width / 2.0;
        top = cy - height / 2.0;
      }
      return RoboflowDetection(
        className: className,
        confidence: confidence,
        bbox: Rect.fromLTWH(left, top, width, height),
      );
    }).toList();
  }
}
