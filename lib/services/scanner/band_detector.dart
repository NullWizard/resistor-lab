import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'scanner_models.dart';

class BandDetector {
  static const String sourceName = "VISION";
  static const String modelName = "gemini-3.5-flash-lite";

  static BandColor stringToColor(String c) {
    switch (c.toLowerCase().trim()) {
      case 'black': return BandColor.black;
      case 'brown': return BandColor.brown;
      case 'red': return BandColor.red;
      case 'orange': return BandColor.orange;
      case 'yellow': return BandColor.yellow;
      case 'green': return BandColor.green;
      case 'blue': return BandColor.blue;
      case 'violet':
      case 'purple': return BandColor.violet;
      case 'grey':
      case 'gray': return BandColor.grey;
      case 'white': return BandColor.white;
      case 'gold': return BandColor.gold;
      case 'silver': return BandColor.silver;
      default: return BandColor.none;
    }
  }

  static Future<RecognitionCandidate> detect(Uint8List imageBytes) async {
    String? apiKey;
    try {
      if (dotenv.isInitialized) {
        apiKey = dotenv.env['APP_SERVICE_KEY'] ?? dotenv.env['GEMINI_API_KEY'];
      }
    } catch (_) {}
    
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_KEY_HERE') {
      return const RecognitionCandidate(
        success: false,
        source: sourceName,
        errorMessage: "Service configuration key is not set.",
      );
    }
    
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.0,
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'is_resistor': Schema.boolean(),
              'success': Schema.boolean(),
              'resistor': Schema.object(
                properties: {
                  'box': Schema.array(items: Schema.number()),
                },
              ),
              'bands': Schema.array(
                items: Schema.object(
                  properties: {
                    'color': Schema.enumString(enumValues: [
                      'black', 'brown', 'red', 'orange', 'yellow', 
                      'green', 'blue', 'violet', 'grey', 'white', 
                      'gold', 'silver'
                    ]),
                    'box': Schema.array(items: Schema.number()),
                    'center_x': Schema.number(),
                    'confidence': Schema.number(),
                  },
                  requiredProperties: ['color'],
                ),
              ),
              'confidence': Schema.number(),
            },
            requiredProperties: ['is_resistor', 'success', 'bands'],
          ),
        ),
      );

      const prompt = '''
You are an expert electronics lab assistant analyzing a photograph of one axial resistor.
1. Determine whether an axial resistor is visible in the image. If not, set is_resistor = false, success = false.
2. If present, detect each painted color band on the resistor body.
3. Return the bands in physical visual order from one side to the other.
Valid band colors are: black, brown, red, orange, yellow, green, blue, violet, grey, white, gold, silver.
Resistors typically have 4, 5, or 6 bands.
Do not invent bands. Report the visual colors clearly and accurately.
''';

      // Detect MIME type (JPEG or PNG)
      String mimeType = 'image/jpeg';
      if (imageBytes.length > 8 &&
          imageBytes[0] == 0x89 &&
          imageBytes[1] == 0x50 &&
          imageBytes[2] == 0x4E &&
          imageBytes[3] == 0x47) {
        mimeType = 'image/png';
      }

      Uint8List imageToSend = imageBytes;
      String sendMime = mimeType;

      // Decode and optimize image if too large for faster API roundtrip
      try {
        final img.Image? decoded = img.decodeImage(imageBytes);
        if (decoded != null && (decoded.width > 1280 || decoded.height > 1280)) {
          final int maxDim = 1280;
          final int w = decoded.width >= decoded.height ? maxDim : (decoded.width * maxDim / decoded.height).round();
          final int h = decoded.height > decoded.width ? maxDim : (decoded.height * maxDim / decoded.width).round();
          final resized = img.copyResize(decoded, width: w, height: h);
          imageToSend = Uint8List.fromList(img.encodeJpg(resized, quality: 85));
          sendMime = 'image/jpeg';
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[BandDetector] Preprocessing fallback: $e');
        }
      }

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart(sendMime, imageToSend),
        ])
      ];

      final response = await model.generateContent(content);
      final jsonStr = response.text;
      if (jsonStr == null || jsonStr.trim().isEmpty) {
        return const RecognitionCandidate(
          success: false,
          source: sourceName,
          errorMessage: "No response from recognition service.",
        );
      }

      if (kDebugMode) {
        debugPrint('[BandDetector] Response: $jsonStr');
      }

      return parseResponse(jsonStr);
    } catch (e) {
      return RecognitionCandidate(
        success: false,
        source: sourceName,
        errorMessage: "Recognition service error: $e",
      );
    }
  }

  static RecognitionCandidate parseResponse(String jsonStr) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      if (data['is_resistor'] == false) {
        return const RecognitionCandidate(
          success: false,
          isResistor: false,
          source: sourceName,
          errorMessage: "No valid resistor detected in image.",
        );
      }
      
      if (data['success'] != true) {
        return const RecognitionCandidate(
          success: false,
          source: sourceName,
          errorMessage: "Could not identify a resistor clearly. Please try again with better lighting.",
        );
      }

      final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.90;

      final List<dynamic> bandsJson = data['bands'] ?? [];
      final int detectedCount = bandsJson.length;
      if (detectedCount < 4 || detectedCount > 6) {
        return RecognitionCandidate(
          success: false,
          source: sourceName,
          errorMessage: "Detected $detectedCount bands. Only 4, 5, or 6 are supported.",
        );
      }

      // Sort bands by center_x if available
      final hasCenterX = bandsJson.every((b) => b is Map && b.containsKey('center_x') && b['center_x'] != null);
      if (hasCenterX) {
        bandsJson.sort((a, b) => (a['center_x'] as num).compareTo(b['center_x'] as num));
      }

      // Extract resistor bounding box if provided
      double rBoxX1 = 0.0;
      double rBodyWidth = 1000.0;
      final resistorData = data['resistor'];
      if (resistorData is Map && resistorData['box'] is List && (resistorData['box'] as List).length >= 4) {
        final List<dynamic> rBox = resistorData['box'];
        rBoxX1 = (rBox[0] as num).toDouble();
        final double rBoxX2 = (rBox[2] as num).toDouble();
        if ((rBoxX2 - rBoxX1).abs() > 0) {
          rBodyWidth = (rBoxX2 - rBoxX1).abs();
        }
      }

      List<DetectedBand> bands = [];
      for (int i = 0; i < bandsJson.length; i++) {
        final b = bandsJson[i];
        final color = stringToColor(b['color']?.toString() ?? '');
        final bandConfidence = (b['confidence'] as num?)?.toDouble() ?? confidence;

        double axisPos = (i + 1) / (detectedCount + 1);
        double bx1 = axisPos - 0.04;
        double bx2 = axisPos + 0.04;

        if (b['center_x'] != null) {
          final double bCenter = (b['center_x'] as num).toDouble();
          axisPos = ((bCenter - rBoxX1) / rBodyWidth).clamp(0.0, 1.0);
        }

        if (b['box'] is List && (b['box'] as List).length >= 4) {
          final List<dynamic> bBox = b['box'];
          bx1 = (((bBox[0] as num).toDouble() - rBoxX1) / rBodyWidth).clamp(0.0, 1.0);
          bx2 = (((bBox[2] as num).toDouble() - rBoxX1) / rBodyWidth).clamp(0.0, 1.0);
        }

        bands.add(DetectedBand(
          color: color,
          axisPosition: axisPos,
          startPosition: bx1,
          endPosition: bx2,
          width: (bx2 - bx1).abs() > 0 ? (bx2 - bx1).abs() : 0.08,
          confidence: bandConfidence,
        ));
      }

      // Standard resistor color code orientation rule:
      // Gold and Silver can NEVER be Band 1 (first significant digit).
      // If the first band is Gold or Silver, the resistor is oriented in reverse.
      if (bands.isNotEmpty && (bands.first.color == BandColor.gold || bands.first.color == BandColor.silver)) {
        bands = bands.reversed.toList();
      }

      return RecognitionCandidate(
        success: true,
        isResistor: true,
        bandCount: bands.length,
        bands: bands,
        overallConfidence: confidence,
        source: sourceName,
      );
    } catch (e) {
      return RecognitionCandidate(
        success: false,
        source: sourceName,
        errorMessage: "JSON Parse Error: $e",
      );
    }
  }
}

