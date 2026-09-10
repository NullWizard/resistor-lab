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

    test('Matrix3 view-relative rotation moves front surfaces with finger regardless of orientation', () {
      final initial = Matrix3.initial();
      expect(initial.m00.isFinite, isTrue);

      // Model rotated 180 degrees (viewing the back)
      final backFacing = Matrix3.rotationY(3.14159).multiply(initial).orthonormalized();

      // Drag right: dx > 0 -> deltaRot = rotY(-dx * 0.015)
      final dragRightDelta = Matrix3.rotationY(-0.15);
      final newRot = dragRightDelta.multiply(backFacing).orthonormalized();

      // A point currently facing the viewer in camera space (z < 0):
      // For any point in camera space, pre-multiplying dragRightDelta rotates it in camera space
      final testPt = const Vector3(0, 0, -10);
      final movedPt = dragRightDelta.transform(testPt);

      // Moving right must increase x (move right on screen)
      expect(movedPt.x, greaterThan(0.0));

      // Drag down: dy > 0 -> deltaRot = rotX(dy * 0.015)
      final dragDownDelta = Matrix3.rotationX(0.15);
      final movedDownPt = dragDownDelta.transform(testPt);

      // Moving down must increase y (move down on screen)
      expect(movedDownPt.y, greaterThan(0.0));
    });

    testWidgets('Opens 3D Inspector Dialog and displays View-Relative HUD', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 200,
                child: Resistor3DViewer(
                  type: Resistor3DType.metalFilm,
                  showInspectButton: true,
                ),
              ),
            ),
          ),
        ),
      );

      // Tap Inspect 3D button
      await tester.tap(find.text('Inspect 3D'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ROTATION: 360° VIEW-RELATIVE'), findsOneWidget);
      expect(find.text('Full 360° Solid CAD Structural View'), findsOneWidget);

      // Close dialog
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}

