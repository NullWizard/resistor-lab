import 'package:flutter_test/flutter_test.dart';
import 'package:resistor_lab/services/scanner/roboflow_service.dart';

void main() {
  group('Roboflow JSON parsing', () {
    const sampleJson = '''
    {
      "predictions": [
        {"class": "resistor", "confidence": 0.95, "bbox": {"x": 10, "y": 20, "width": 200, "height": 50}},
        {"class": "brown", "confidence": 0.80, "bbox": {"x": 30, "y": 25, "width": 20, "height": 40}},
        {"class": "purple", "confidence": 0.03, "bbox": {"x": 60, "y": 25, "width": 20, "height": 40}}
      ]
    }''';

    test('parses detections correctly', () {
      final service = RoboflowService.instance;
      final detections = service.parseDetections(sampleJson);

      expect(detections, hasLength(3));
      // Resistor detection
      expect(detections[0].className, 'resistor');
      expect(detections[0].confidence, closeTo(0.95, 0.0001));
      expect(detections[0].bbox.left, 10);
      // Brown detection
      expect(detections[1].className, 'brown');
      expect(detections[1].confidence, closeTo(0.80, 0.0001));
      // Purple should be mapped to violet
      expect(detections[2].className, 'violet');
      expect(detections[2].confidence, closeTo(0.03, 0.0001));
    });

    test('confidence floor does not discard low values (parser keeps them)', () {
      final service = RoboflowService.instance;
      final detections = service.parseDetections(sampleJson);
      expect(detections.any((d) => d.confidence == 0.03), isTrue);
    });
  });
}
