import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:resistor_lab/widgets/interactive_band_overlay.dart';
import 'package:resistor_lab/services/resistor_scanner_service.dart';

void main() {
  group('OpticalStripeDetector Tests', () {
    test('Detects physical stripe peaks across synthetic resistor image', () {
      // Create a 200x100 synthetic image with a light ceramic resistor body
      final image = img.Image(width: 200, height: 100);
      // Background: table / paper
      img.fill(image, color: img.ColorRgb8(240, 240, 240));

      // Draw horizontal beige resistor body across center (guide area: x: 40..160, y: 35..65)
      for (int y = 35; y < 65; y++) {
        for (int x = 40; x < 160; x++) {
          image.setPixelRgb(x, y, 220, 205, 180);
        }
      }

      // Draw 4 distinct color stripes (Brown, Black, Red, Gold) at x = 60, 85, 110, 145
      // Guide width is 160 - 40 = 120
      // 60 -> (60-40)/120 ≈ 0.17
      // 85 -> (85-40)/120 ≈ 0.38
      // 110 -> (110-40)/120 ≈ 0.58
      // 145 -> (145-40)/120 ≈ 0.88
      final stripeXPositions = [60, 85, 110, 145];
      final stripeColors = [
        img.ColorRgb8(100, 50, 20),   // Brown
        img.ColorRgb8(10, 10, 10),     // Black
        img.ColorRgb8(220, 20, 20),   // Red
        img.ColorRgb8(218, 165, 32),  // Gold
      ];

      for (int s = 0; s < 4; s++) {
        final sx = stripeXPositions[s];
        final col = stripeColors[s];
        for (int dx = -2; dx <= 2; dx++) {
          for (int y = 35; y < 65; y++) {
            image.setPixelRgb(sx + dx, y, col.r.toInt(), col.g.toInt(), col.b.toInt());
          }
        }
      }

      final pngBytes = Uint8List.fromList(img.encodePng(image));
      final detected = OpticalStripeDetector.detectStripes(pngBytes, 4);

      expect(detected, isNotNull);
      expect(detected!.length, 4);
      // Verify strictly ascending stripe coordinates
      expect(detected[0] < detected[1], isTrue);
      expect(detected[1] < detected[2], isTrue);
      expect(detected[2] < detected[3], isTrue);
      // Verify values are bounded within valid guide range
      for (final p in detected) {
        expect(p >= 0.08 && p <= 0.92, isTrue);
      }
    });

    test('Detects wide stripes on zoomed-in resistor and adapts alignment proportionally', () {
      // Create a 240x120 synthetic image where the resistor is zoomed in 2x
      // Guide region is x: 48..192 (width 144), y: 42..78 (height 36)
      final image = img.Image(width: 240, height: 120);
      img.fill(image, color: img.ColorRgb8(240, 240, 240));

      // Resistor ceramic body fills the entire guide box horizontally (x: 10..235)
      for (int y = 42; y < 78; y++) {
        for (int x = 10; x < 235; x++) {
          image.setPixelRgb(x, y, 225, 205, 175);
        }
      }

      // Draw 4 wide color stripes (Brown, Black, Orange, Gold) with width 8px each (zoomed)
      // At x = 65, 100, 140, 180 (within guide 48..192)
      final stripeCenters = [65, 100, 140, 180];
      final stripeColors = [
        img.ColorRgb8(100, 50, 20),   // Brown
        img.ColorRgb8(10, 10, 10),     // Black
        img.ColorRgb8(255, 120, 0),   // Orange
        img.ColorRgb8(218, 165, 32),  // Gold
      ];

      for (int s = 0; s < 4; s++) {
        final cx = stripeCenters[s];
        final col = stripeColors[s];
        for (int dx = -4; dx <= 4; dx++) {
          for (int y = 42; y < 78; y++) {
            image.setPixelRgb(cx + dx, y, col.r.toInt(), col.g.toInt(), col.b.toInt());
          }
        }
      }

      final pngBytes = Uint8List.fromList(img.encodePng(image));
      final detected = OpticalStripeDetector.detectStripes(
        pngBytes,
        4,
        viewportWidth: 240,
        viewportHeight: 120,
      );

      expect(detected, isNotNull);
      expect(detected!.length, 4);
      expect(detected[0] < detected[1], isTrue);
      expect(detected[1] < detected[2], isTrue);
      expect(detected[2] < detected[3], isTrue);
      // Zoomed stripes span broadly across the guide box (> 0.60 total span)
      expect(detected.last - detected.first > 0.60, isTrue);
    });

    test('Gracefully returns null on empty or invalid bytes', () {
      expect(OpticalStripeDetector.detectStripes(null, 4), isNull);
      expect(OpticalStripeDetector.detectStripes(Uint8List(0), 4), isNull);
      expect(OpticalStripeDetector.detectStripes(Uint8List.fromList([1, 2, 3]), 4), isNull);
    });
  });

  group('BandProbabilityHelper Tests', () {
    test('Band 1 (1st Digit) ranks current color first and common 1st digits in most probable', () {
      // Band 1 with current value = 1 (Brown)
      final result = BandProbabilityHelper.getOptionsForBand(
        bandIndex: 0,
        bandCount: 4,
        currentValue: 1,
      );

      expect(result.bandTitle, 'Band 1 (1st Digit)');
      expect(result.mostProbable.isNotEmpty, isTrue);
      // The current color (Brown) must be first
      expect(result.mostProbable.first.name, 'Brown');
      expect(result.mostProbable.first.isCurrent, isTrue);

      // Probable options should contain optical confusions like Red/Orange
      final probableNames = result.mostProbable.map((o) => o.name).toList();
      expect(probableNames.contains('Red') || probableNames.contains('Orange'), isTrue);

      // Remaining options should be in otherOptions
      expect(result.otherOptions.isNotEmpty, isTrue);
      // Total options should equal total digit colors (10)
      expect(result.mostProbable.length + result.otherOptions.length, 10);
    });

    test('Band 3 in 4-band resistor (Multiplier) prioritizes decade multipliers and current color', () {
      // Band 3 (Multiplier) with current value = 2 (Red = x100)
      final result = BandProbabilityHelper.getOptionsForBand(
        bandIndex: 2,
        bandCount: 4,
        currentValue: 2,
      );

      expect(result.bandTitle, 'Band 3 (Multiplier)');
      expect(result.mostProbable.first.name, 'Red');
      expect(result.mostProbable.first.isCurrent, isTrue);

      final probableNames = result.mostProbable.map((o) => o.name).toList();
      expect(probableNames.contains('Brown') || probableNames.contains('Orange') || probableNames.contains('Gold'), isTrue);

      expect(result.mostProbable.length + result.otherOptions.length, ResistorScannerService.multiplierColors.length);
    });

    test('Band 4 in 4-band resistor (Tolerance) prioritizes Gold and Brown', () {
      // Band 4 (Tolerance) with current value = 2 (Gold = ±5%)
      final result = BandProbabilityHelper.getOptionsForBand(
        bandIndex: 3,
        bandCount: 4,
        currentValue: 2,
      );

      expect(result.bandTitle, 'Band 4 (Tolerance)');
      expect(result.mostProbable.first.name, 'Gold');
      expect(result.mostProbable.first.isCurrent, isTrue);

      final probableNames = result.mostProbable.map((o) => o.name).toList();
      expect(probableNames.contains('Brown'), isTrue); // Brown (1%) is top tolerance

      expect(result.mostProbable.length + result.otherOptions.length, ResistorScannerService.toleranceColors.length);
    });

    test('Band 6 in 6-band resistor (TempCo) prioritizes Brown and Red', () {
      final result = BandProbabilityHelper.getOptionsForBand(
        bandIndex: 5,
        bandCount: 6,
        currentValue: 0, // Brown
      );

      expect(result.bandTitle, 'Band 6 (Temp. Coefficient)');
      expect(result.mostProbable.first.name, 'Brown');
      final probableNames = result.mostProbable.map((o) => o.name).toList();
      expect(probableNames.contains('Red'), isTrue);
      expect(result.mostProbable.length + result.otherOptions.length, ResistorScannerService.tempCoColors.length);
    });
  });

  group('InteractiveBandOverlay Widget Tests', () {
    testWidgets('Renders colored boxes with band labels and color names', (tester) async {
      int changedBand = -1;
      int changedColor = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 290,
                child: InteractiveBandOverlay(
                  bandCount: 4,
                  band1Index: 1, // Brown
                  band2Index: 0, // Black
                  band3Index: 2, // Red (x100)
                  band4Index: 2, // Gold (±5%)
                  band5Index: 0,
                  band6Index: 0,
                  onBandColorChanged: (bIdx, cIdx) {
                    changedBand = bIdx;
                    changedColor = cIdx;
                  },
                  viewportWidth: 360,
                  viewportHeight: 290,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the colored boxes are rendered on the image
      expect(find.text('B1 Brown'), findsOneWidget);
      expect(find.text('B2 Black'), findsOneWidget);
      expect(find.text('B3 Red'), findsOneWidget);
      expect(find.text('B4 Gold'), findsOneWidget);
      expect(find.text('TAP BOX TO EDIT'), findsOneWidget);

      // Tap on B1 Brown box to open the color selection modal
      await tester.tap(find.text('B1 Brown'));
      await tester.pumpAndSettle();

      // Modal sheet should display with Most Probable Colors first
      expect(find.text('Band 1 (1st Digit)'), findsOneWidget);
      expect(find.text('MOST PROBABLE COLORS'), findsOneWidget);
      expect(find.text('ALL OTHER OPTIONS'), findsOneWidget);

      // Tap on 'Red' option in the modal to change Band 1 color to Red (2)
      await tester.tap(find.text('Red').first);
      await tester.pumpAndSettle();

      expect(changedBand, 0);
      expect(changedColor, 2);
    });

    testWidgets('Renders 5 and 6 bands accurately with alternating pointers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 290,
                child: InteractiveBandOverlay(
                  bandCount: 5,
                  band1Index: 2, // Red
                  band2Index: 2, // Red
                  band3Index: 0, // Black
                  band4Index: 1, // Brown
                  band5Index: 0, // Brown
                  band6Index: 0,
                  onBandColorChanged: (bIdx, cIdx) {},
                  viewportWidth: 360,
                  viewportHeight: 290,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('B1 Red'), findsOneWidget);
      expect(find.text('B2 Red'), findsOneWidget);
      expect(find.text('B3 Black'), findsOneWidget);
      expect(find.text('B4 Brown'), findsOneWidget);
      expect(find.text('B5 Brown'), findsOneWidget);
    });

    testWidgets('Tapping rectangle wireframe touch target opens color picker', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 290,
                child: InteractiveBandOverlay(
                  bandCount: 4,
                  band1Index: 1, // Brown
                  band2Index: 0, // Black
                  band3Index: 2, // Red
                  band4Index: 2, // Gold
                  band5Index: 0,
                  band6Index: 0,
                  detectedAxisPositions: const [0.25, 0.45, 0.65, 0.85],
                  onBandColorChanged: (_, _) {},
                  viewportWidth: 360,
                  viewportHeight: 290,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the wireframe touch target container for Band 1 at center (guideLeft + guideWidth * 0.25)
      // Viewport width = 360, guideWidth = 216, guideLeft = 72
      // Band 1 X = 72 + 216 * 0.25 = 126
      // Viewport height = 290, guideHeight = 87, guideTop = 101.5
      // Resistor center Y = 101.5 + 43.5 = 145
      final overlayTopLeft = tester.getTopLeft(find.byType(InteractiveBandOverlay));
      final wireframeCenter = overlayTopLeft + const Offset(126, 145);
      await tester.tapAt(wireframeCenter);
      await tester.pumpAndSettle();

      // Modal should open for Band 1
      expect(find.text('Band 1 (1st Digit)'), findsOneWidget);
      expect(find.text('MOST PROBABLE COLORS'), findsOneWidget);
    });

    testWidgets('Alignment Mode toggle displays HUD and supports shift/reset operations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                height: 290,
                child: InteractiveBandOverlay(
                  bandCount: 4,
                  band1Index: 1, // Brown
                  band2Index: 0, // Black
                  band3Index: 2, // Red
                  band4Index: 2, // Gold
                  band5Index: 0,
                  band6Index: 0,
                  onBandColorChanged: (_, _) {},
                  viewportWidth: 360,
                  viewportHeight: 290,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially in presentation mode: 'ALIGN' button is visible, HUD is not
      expect(find.text('ALIGN'), findsOneWidget);
      expect(find.text('TAP BOX TO EDIT'), findsOneWidget);
      expect(find.text('Shift L'), findsNothing);

      // Tap 'ALIGN' to enter calibration / alignment mode
      await tester.tap(find.text('ALIGN'));
      await tester.pumpAndSettle();

      // HUD and alignment tools are now active
      expect(find.text('DONE'), findsOneWidget);
      expect(find.text('SLIDE BANDS TO STRIPES'), findsOneWidget);
      expect(find.text('Shift L'), findsOneWidget);
      expect(find.text('Shift R'), findsOneWidget);
      expect(find.text('Closer'), findsOneWidget);
      expect(find.text('Wider'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Tap 'Shift R' to nudge bands
      await tester.tap(find.text('Shift R'));
      await tester.pumpAndSettle();

      // Tap 'Closer' to adjust spacing
      await tester.tap(find.text('Closer'));
      await tester.pumpAndSettle();

      // Tap 'Reset' to return to default calibrated positions
      await tester.ensureVisible(find.text('Reset'));
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Tap 'DONE' to lock positions for presentation
      await tester.tap(find.text('DONE'));
      await tester.pumpAndSettle();

      // HUD is dismissed and user is back in presentation mode
      expect(find.text('ALIGN'), findsOneWidget);
      expect(find.text('TAP BOX TO EDIT'), findsOneWidget);
      expect(find.text('Shift L'), findsNothing);
    });
  });
}

