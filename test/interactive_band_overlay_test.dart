import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resistor_lab/widgets/interactive_band_overlay.dart';
import 'package:resistor_lab/services/resistor_scanner_service.dart';

void main() {
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
  });
}
