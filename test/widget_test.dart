
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:resistor_lab/services/scanner/scanner_models.dart';
import 'package:resistor_lab/services/scanner/paper_cv_detector.dart';
import 'package:resistor_lab/services/scanner/ensemble_engine.dart';
import 'package:image/image.dart' as img;

Uint8List createResistorImage({
  required List<int> bandColors, // R,G,B for each band
  bool reversed = false,
  double shiftX = 0.0,
  double rotation = 0.0,
  bool shadow = false,
  bool highlight = false,
  bool ceramic = false,
  bool whiteBg = false,
  bool isFace = false,
}) {
  final image = img.Image(width: 200, height: 100);
  int bgR = whiteBg ? 255 : 20;
  int bgG = whiteBg ? 255 : 20;
  int bgB = whiteBg ? 255 : 20;

  for (int y = 0; y < 100; y++) {
    for (int x = 0; x < 200; x++) {
      if (isFace) {
         image.setPixelRgb(x, y, 200, 150, 120);
         continue;
      }
      
      double rx = x.toDouble();
      double ry = y.toDouble();
      
      rx -= 100; ry -= 50;
      double crx = rx * 1 + ry * -rotation;
      double cry = rx * rotation + ry * 1;
      crx += 100; cry += 50;
      crx -= shiftX;

      if (crx >= 40 && crx <= 160 && cry >= 35 && cry <= 65) {
        int r = ceramic ? 190 : 160;
        int g = ceramic ? 160 : 130;
        int b = ceramic ? 140 : 110;
        
        List<int> bands = reversed ? bandColors.reversed.toList() : bandColors;
        int count = bands.length ~/ 3;
        double gap = 120.0 / (count + 1);
        
        for (int i = 0; i < count; i++) {
          double bx = 40 + gap * (i + 1);
          if (count == 4 && i == 3) bx += 10;
          if (count == 5 && i == 4) bx += 10;
          
          if ((crx - bx).abs() < 5) {
             int cIndex = i * 3;
             r = bands[cIndex]; g = bands[cIndex+1]; b = bands[cIndex+2];
          }
        }
        
        if (shadow) { r -= 20; g -= 20; b -= 20; }
        if (highlight && cry < 45) { r += 40; g += 40; b += 40; }
        
        image.setPixelRgb(x, y, r.clamp(0,255), g.clamp(0,255), b.clamp(0,255));
      } else {
        image.setPixelRgb(x, y, bgR, bgG, bgB);
      }
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  group('PaperCvDetector', () {
    testWidgets('4-band resistor', (tester) async {
       final imgBytes = createResistorImage(bandColors: [
         110, 70, 50,  // Brown
         40, 40, 40,   // Black
         200, 50, 50,  // Red
         180, 140, 60, // Gold
       ]);
       final result = await PaperCvDetector.detect(imgBytes);
       expect(result.success, true);
       expect(result.bandCount >= 4, true);
       expect(result.bands[0].color, BandColor.brown);
       expect(result.bands[1].color, BandColor.black);
       expect(result.bands[2].color, BandColor.red);
       expect(result.bands[3].color, BandColor.gold);
    });

    testWidgets('5-band resistor', (tester) async {
       final imgBytes = createResistorImage(bandColors: [
         110, 70, 50,
         40, 40, 40,
         40, 40, 40,
         200, 50, 50,
         110, 70, 50,
       ]);
       final result = await PaperCvDetector.detect(imgBytes);
       expect(result.success, true);
       expect(result.bandCount >= 5, true);
       expect(result.bands[2].color, BandColor.black);
    });
    
    testWidgets('Slight rotation', (tester) async {
       final imgBytes = createResistorImage(bandColors: [
         110, 70, 50,  40, 40, 40,  200, 50, 50,  180, 140, 60,
       ], rotation: 0.15);
       final result = await PaperCvDetector.detect(imgBytes);
       expect(result.success, true);
       expect(result.bandCount >= 4, true);
    });

    testWidgets('Non-resistor image', (tester) async {
       final imgBytes = createResistorImage(bandColors: [], isFace: true);
       final result = await PaperCvDetector.detect(imgBytes);
       expect(result.success, false);
    });
  });

  group('EnsembleEngine Voting', () {
    test('Conflicting detector results', () {
      final gemini = RecognitionCandidate(
        success: true, source: 'GEMINI', bandCount: 4, overallConfidence: 0.9,
        bands: [
          DetectedBand(color: BandColor.brown, axisPosition: 0.2, startPosition: 0.1, endPosition: 0.3, width: 0.2, confidence: 0.9),
          DetectedBand(color: BandColor.orange, axisPosition: 0.4, startPosition: 0.3, endPosition: 0.5, width: 0.2, confidence: 0.9),
          DetectedBand(color: BandColor.red, axisPosition: 0.6, startPosition: 0.5, endPosition: 0.7, width: 0.2, confidence: 0.9),
          DetectedBand(color: BandColor.silver, axisPosition: 0.8, startPosition: 0.7, endPosition: 0.9, width: 0.2, confidence: 0.9),
        ]
      );
      final classical = RecognitionCandidate(
        success: true, source: 'PAPER_CV', bandCount: 4, overallConfidence: 0.8,
        bands: [
          DetectedBand(color: BandColor.brown, axisPosition: 0.2, startPosition: 0.1, endPosition: 0.3, width: 0.2, confidence: 0.8),
          DetectedBand(color: BandColor.orange, axisPosition: 0.4, startPosition: 0.3, endPosition: 0.5, width: 0.2, confidence: 0.8),
          DetectedBand(color: BandColor.red, axisPosition: 0.6, startPosition: 0.5, endPosition: 0.7, width: 0.2, confidence: 0.8),
          DetectedBand(color: BandColor.silver, axisPosition: 0.8, startPosition: 0.7, endPosition: 0.9, width: 0.2, confidence: 0.8),
        ]
      );
      final centerline = RecognitionCandidate(
        success: true, source: 'CENTERLINE', bandCount: 4, overallConfidence: 0.5,
        bands: [
          DetectedBand(color: BandColor.brown, axisPosition: 0.2, startPosition: 0.1, endPosition: 0.3, width: 0.2, confidence: 0.5),
          DetectedBand(color: BandColor.orange, axisPosition: 0.4, startPosition: 0.3, endPosition: 0.5, width: 0.2, confidence: 0.5),
          DetectedBand(color: BandColor.red, axisPosition: 0.6, startPosition: 0.5, endPosition: 0.7, width: 0.2, confidence: 0.5),
          DetectedBand(color: BandColor.brown, axisPosition: 0.8, startPosition: 0.7, endPosition: 0.9, width: 0.2, confidence: 0.5),
        ]
      );

      final result = EnsembleEngine.computeConsensus([gemini, classical, centerline]);
      expect(result.success, true);
      expect(result.bandCount >= 4, true);
      expect(result.bands[0].color, BandColor.brown);
      expect(result.bands[1].color, BandColor.orange);
      expect(result.bands[2].color, BandColor.red);
      expect(result.bands[3].color, BandColor.silver);
      expect(result.bands[3].needsConfirmation, false); // Because 2 out of 3 agreed, but wait, total confidence > 0.6
    });
    
    test('Band count voting', () {
       final c1 = RecognitionCandidate(success: true, source: 'GEMINI', bandCount: 4, overallConfidence: 0.9, bands: List.generate(4, (i)=>DetectedBand(color: BandColor.black, axisPosition: 0.1 + i*0.2, startPosition: 0, endPosition: 0.2, width: 0.2, confidence: 0.9)));
       final c2 = RecognitionCandidate(success: true, source: 'PAPER_CV', bandCount: 4, overallConfidence: 0.7, bands: List.generate(4, (i)=>DetectedBand(color: BandColor.black, axisPosition: 0.1 + i*0.2, startPosition: 0, endPosition: 0.2, width: 0.2, confidence: 0.9)));
       final c3 = RecognitionCandidate(success: true, source: 'CENTERLINE', bandCount: 5, overallConfidence: 0.5, bands: List.generate(5, (i)=>DetectedBand(color: BandColor.black, axisPosition: 0.1 + i*0.2, startPosition: 0, endPosition: 0.2, width: 0.2, confidence: 0.9)));
       final result = EnsembleEngine.computeConsensus([c1, c2, c3]);
       expect(result.bandCount >= 4, true);
    });
  });
}
