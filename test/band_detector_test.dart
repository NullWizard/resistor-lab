import 'package:flutter_test/flutter_test.dart';
import 'package:resistor_lab/services/scanner/band_detector.dart';
import 'package:resistor_lab/services/scanner/scanner_models.dart';

void main() {
  group('BandDetector parser tests', () {
    test('parses normal 4-band JSON response with correct colors and confidence', () {
      const jsonStr = '''
      {
        "is_resistor": true,
        "success": true,
        "confidence": 0.95,
        "resistor": {
          "box": [100, 200, 500, 300]
        },
        "bands": [
          {"color": "brown", "center_x": 150, "confidence": 0.98},
          {"color": "black", "center_x": 220, "confidence": 0.97},
          {"color": "red", "center_x": 300, "confidence": 0.96},
          {"color": "gold", "center_x": 420, "confidence": 0.95}
        ]
      }
      ''';

      final result = BandDetector.parseResponse(jsonStr);

      expect(result.success, isTrue);
      expect(result.isResistor, isTrue);
      expect(result.bandCount, equals(4));
      expect(result.bands[0].color, equals(BandColor.brown));
      expect(result.bands[1].color, equals(BandColor.black));
      expect(result.bands[2].color, equals(BandColor.red));
      expect(result.bands[3].color, equals(BandColor.gold));
      expect(result.overallConfidence, equals(0.95));
      expect(result.source, equals("VISION"));
    });

    test('reverses band order if first band is gold (tolerance read backward)', () {
      const jsonStr = '''
      {
        "is_resistor": true,
        "success": true,
        "confidence": 0.92,
        "bands": [
          {"color": "gold", "center_x": 120},
          {"color": "red", "center_x": 200},
          {"color": "black", "center_x": 280},
          {"color": "brown", "center_x": 360}
        ]
      }
      ''';

      final result = BandDetector.parseResponse(jsonStr);

      expect(result.success, isTrue);
      expect(result.bandCount, equals(4));
      expect(result.bands[0].color, equals(BandColor.brown));
      expect(result.bands[1].color, equals(BandColor.black));
      expect(result.bands[2].color, equals(BandColor.red));
      expect(result.bands[3].color, equals(BandColor.gold));
    });

    test('maps alternative color names like purple -> violet, gray -> grey', () {
      expect(BandDetector.stringToColor('purple'), equals(BandColor.violet));
      expect(BandDetector.stringToColor('violet'), equals(BandColor.violet));
      expect(BandDetector.stringToColor('gray'), equals(BandColor.grey));
      expect(BandDetector.stringToColor('grey'), equals(BandColor.grey));
      expect(BandDetector.stringToColor('BROWN'), equals(BandColor.brown));
    });

    test('handles 5-band and 6-band resistors correctly', () {
      const json5 = '''
      {
        "is_resistor": true,
        "success": true,
        "bands": [
          {"color": "yellow"},
          {"color": "violet"},
          {"color": "black"},
          {"color": "orange"},
          {"color": "brown"}
        ]
      }
      ''';
      final res5 = BandDetector.parseResponse(json5);
      expect(res5.success, isTrue);
      expect(res5.bandCount, equals(5));
      expect(res5.bands[0].color, equals(BandColor.yellow));
      expect(res5.bands[4].color, equals(BandColor.brown));

      const json6 = '''
      {
        "is_resistor": true,
        "success": true,
        "bands": [
          {"color": "blue"},
          {"color": "grey"},
          {"color": "black"},
          {"color": "red"},
          {"color": "gold"},
          {"color": "blue"}
        ]
      }
      ''';
      final res6 = BandDetector.parseResponse(json6);
      expect(res6.success, isTrue);
      expect(res6.bandCount, equals(6));
      expect(res6.bands[5].color, equals(BandColor.blue));
    });

    test('rejects image when is_resistor is false', () {
      const jsonStr = '{"is_resistor": false, "success": false, "bands": []}';
      final result = BandDetector.parseResponse(jsonStr);
      expect(result.success, isFalse);
      expect(result.isResistor, isFalse);
    });

    test('rejects unsupported band counts (<4 or >6)', () {
      const json3 = '''
      {
        "is_resistor": true,
        "success": true,
        "bands": [
          {"color": "red"},
          {"color": "red"},
          {"color": "brown"}
        ]
      }
      ''';
      final result = BandDetector.parseResponse(json3);
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Detected 3 bands'));
    });
  });
}
