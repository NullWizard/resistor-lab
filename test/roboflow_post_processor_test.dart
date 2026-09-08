import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:resistor_lab/services/scanner/roboflow_post_processor.dart';
import 'package:resistor_lab/services/scanner/scanner_models.dart';

void main() {
  group('RoboflowPostProcessor', () {
    test('Horizontal 4-band resistor: Brown-Black-Red-Gold', () {
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.95,
          bbox: Rect.fromLTWH(100, 100, 400, 100),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.90,
          bbox: Rect.fromLTWH(140, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'black',
          confidence: 0.85,
          bbox: Rect.fromLTWH(200, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.88,
          bbox: Rect.fromLTWH(260, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'gold',
          confidence: 0.92,
          bbox: Rect.fromLTWH(340, 110, 20, 80),
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.orientationDirection, 'horizontal');
      expect(result.bandCount, 4);
      expect(result.bands[0].color, BandColor.brown);
      expect(result.bands[1].color, BandColor.black);
      expect(result.bands[2].color, BandColor.red);
      expect(result.bands[3].color, BandColor.gold);
      expect(result.overallConfidence, greaterThan(0.8));
    });

    test('Vertical 4-band resistor: Brown-Orange-Red-Silver', () {
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.94,
          bbox: Rect.fromLTWH(100, 100, 100, 400),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.91,
          bbox: Rect.fromLTWH(110, 140, 80, 20),
        ),
        const RoboflowDetection(
          className: 'orange',
          confidence: 0.89,
          bbox: Rect.fromLTWH(110, 200, 80, 20),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.87,
          bbox: Rect.fromLTWH(110, 260, 80, 20),
        ),
        const RoboflowDetection(
          className: 'silver',
          confidence: 0.90,
          bbox: Rect.fromLTWH(110, 340, 80, 20),
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.orientationDirection, 'vertical');
      expect(result.bandCount, 4);
      expect(result.bands[0].color, BandColor.brown);
      expect(result.bands[1].color, BandColor.orange);
      expect(result.bands[2].color, BandColor.red);
      expect(result.bands[3].color, BandColor.silver);
    });

    test('Diagonal resistor ~45 degrees', () {
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.90,
          bbox: Rect.fromLTWH(50, 50, 300, 300),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.85,
          bbox: Rect.fromLTWH(80, 80, 25, 25),
        ),
        const RoboflowDetection(
          className: 'black',
          confidence: 0.80,
          bbox: Rect.fromLTWH(140, 140, 25, 25),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.82,
          bbox: Rect.fromLTWH(200, 200, 25, 25),
        ),
        const RoboflowDetection(
          className: 'gold',
          confidence: 0.88,
          bbox: Rect.fromLTWH(260, 260, 25, 25),
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.orientationDirection, 'diagonal');
      expect(result.bandCount, 4);
      expect(result.bands[0].color, BandColor.brown);
      expect(result.bands[1].color, BandColor.black);
      expect(result.bands[2].color, BandColor.red);
      expect(result.bands[3].color, BandColor.gold);
    });

    test('Reversed physical direction is correctly flipped', () {
      // Gold at start (x=140), Brown at end (x=340) -> Should flip to Brown-Black-Red-Gold
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.95,
          bbox: Rect.fromLTWH(100, 100, 400, 100),
        ),
        const RoboflowDetection(
          className: 'gold',
          confidence: 0.92,
          bbox: Rect.fromLTWH(140, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.88,
          bbox: Rect.fromLTWH(200, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'black',
          confidence: 0.85,
          bbox: Rect.fromLTWH(260, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.90,
          bbox: Rect.fromLTWH(340, 110, 20, 80),
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.bandCount, 4);
      expect(result.bands[0].color, BandColor.brown);
      expect(result.bands[1].color, BandColor.black);
      expect(result.bands[2].color, BandColor.red);
      expect(result.bands[3].color, BandColor.gold);
    });

    test('Duplicate detection suppression keeps higher confidence', () {
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.95,
          bbox: Rect.fromLTWH(100, 100, 400, 100),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.90,
          bbox: Rect.fromLTWH(140, 110, 20, 80),
        ),
        // Duplicate brown nearby with lower confidence
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.50,
          bbox: Rect.fromLTWH(142, 111, 20, 80),
        ),
        const RoboflowDetection(
          className: 'black',
          confidence: 0.85,
          bbox: Rect.fromLTWH(200, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.88,
          bbox: Rect.fromLTWH(260, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'gold',
          confidence: 0.92,
          bbox: Rect.fromLTWH(340, 110, 20, 80),
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.bandCount, 4);
      expect(result.bands[0].color, BandColor.brown);
      expect(result.bands[0].confidence, 0.90);
    });

    test('Low-confidence band (0.03) is retained if spatially valid', () {
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.95,
          bbox: Rect.fromLTWH(100, 100, 400, 100),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.90,
          bbox: Rect.fromLTWH(140, 110, 20, 80),
        ),
        // Low-confidence black band (0.03)
        const RoboflowDetection(
          className: 'black',
          confidence: 0.03,
          bbox: Rect.fromLTWH(200, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.88,
          bbox: Rect.fromLTWH(260, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'gold',
          confidence: 0.92,
          bbox: Rect.fromLTWH(340, 110, 20, 80),
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.bandCount, 4);
      expect(result.bands[1].color, BandColor.black);
      expect(result.bands[1].confidence, closeTo(0.03, 0.001));
    });

    test('Tolerance detection does NOT require spacing outlier (normal spacing accepted)', () {
      // All bands are evenly spaced with exactly 60px between them (no gap outlier)
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.95,
          bbox: Rect.fromLTWH(100, 100, 400, 100),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.90,
          bbox: Rect.fromLTWH(140, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'black',
          confidence: 0.85,
          bbox: Rect.fromLTWH(200, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.88,
          bbox: Rect.fromLTWH(260, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'gold',
          confidence: 0.92,
          bbox: Rect.fromLTWH(320, 110, 20, 80), // normal 60px spacing!
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.bandCount, 4);
      expect(result.bands[3].color, BandColor.gold);
    });

    test('5-band resistor validity', () {
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.95,
          bbox: Rect.fromLTWH(100, 100, 500, 100),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.90,
          bbox: Rect.fromLTWH(130, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'black',
          confidence: 0.85,
          bbox: Rect.fromLTWH(190, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'black',
          confidence: 0.88,
          bbox: Rect.fromLTWH(250, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'orange',
          confidence: 0.87,
          bbox: Rect.fromLTWH(310, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.91,
          bbox: Rect.fromLTWH(400, 110, 20, 80),
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.bandCount, 5);
      expect(result.bands[0].color, BandColor.brown);
      expect(result.bands[1].color, BandColor.black);
      expect(result.bands[2].color, BandColor.black);
      expect(result.bands[3].color, BandColor.orange);
      expect(result.bands[4].color, BandColor.brown);
    });

    test('6-band resistor validity with tempCo', () {
      final detections = [
        const RoboflowDetection(
          className: 'resistor',
          confidence: 0.95,
          bbox: Rect.fromLTWH(100, 100, 600, 100),
        ),
        const RoboflowDetection(
          className: 'yellow',
          confidence: 0.90,
          bbox: Rect.fromLTWH(130, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'violet',
          confidence: 0.85,
          bbox: Rect.fromLTWH(190, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'black',
          confidence: 0.88,
          bbox: Rect.fromLTWH(250, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.87,
          bbox: Rect.fromLTWH(310, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'brown',
          confidence: 0.91,
          bbox: Rect.fromLTWH(380, 110, 20, 80),
        ),
        const RoboflowDetection(
          className: 'red',
          confidence: 0.89,
          bbox: Rect.fromLTWH(460, 110, 20, 80),
        ),
      ];

      final result = RoboflowPostProcessor.process(detections);
      expect(result.success, isTrue);
      expect(result.bandCount, 6);
      expect(result.bands[0].color, BandColor.yellow);
      expect(result.bands[1].color, BandColor.violet);
      expect(result.bands[2].color, BandColor.black);
      expect(result.bands[3].color, BandColor.red);
      expect(result.bands[4].color, BandColor.brown);
      expect(result.bands[5].color, BandColor.red);
    });
  });
}
