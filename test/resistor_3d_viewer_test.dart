import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resistor_lab/widgets/resistor_3d_viewer.dart';

void main() {
  group('Resistor3DViewer Tests', () {
    for (final type in Resistor3DType.values) {
      testWidgets('Renders $type without errors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 200,
                  child: Resistor3DViewer(
                    type: type,
                    enableGesture: true,
                    showInspectButton: true,
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Resistor3DViewer), findsOneWidget);
        expect(find.text('3D CAD MODEL'), findsOneWidget);

        // Simulate interactive drag rotation
        await tester.drag(find.byType(Resistor3DViewer), const Offset(50, -30));
        await tester.pump();

        // Simulate another rotation
        await tester.drag(find.byType(Resistor3DViewer), const Offset(-80, 60));
        await tester.pump();

        // Let double-tap recognition timer complete
        await tester.pump(const Duration(milliseconds: 500));
      });
    }
  });
}
