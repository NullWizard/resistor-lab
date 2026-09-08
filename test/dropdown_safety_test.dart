import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resistor_lab/screens/calculator_screen.dart';
import 'package:resistor_lab/screens/scan_resistor_screen.dart';

void main() {
  testWidgets('CalculatorScreen switches between 4, 5, and 6 bands without Dropdown assertion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CalculatorScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial 4 bands mode
    expect(find.text('4'), findsOneWidget);

    // Switch to 5 bands
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();

    // Switch to 6 bands
    await tester.tap(find.text('6'));
    await tester.pumpAndSettle();

    // Switch back to 4 bands
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    // Switch to 5 bands again
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
  });

  testWidgets('ScanResistorScreen renders scanner_band_count_dropdown safely', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ScanResistorScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ScanResistorScreen), findsOneWidget);
  });
}
