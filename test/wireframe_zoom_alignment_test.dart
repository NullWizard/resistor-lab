import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:resistor_lab/widgets/interactive_band_overlay.dart';

/// Simulates the exact `_extractPositionedRegion` transform from `ScanResistorScreen`
Uint8List extractTransformedRegion({
  required img.Image srcImg,
  required double zoom,
  required double dx,
  required double dy,
  required double viewportWidth,
  required double viewportHeight,
}) {
  final double srcW = srcImg.width.toDouble();
  final double srcH = srcImg.height.toDouble();

  final double scaleFit = math.min(viewportWidth / srcW, viewportHeight / srcH);
  final double fittedW = srcW * scaleFit;
  final double fittedH = srcH * scaleFit;
  final double offsetX = (viewportWidth - fittedW) / 2.0;
  final double offsetY = (viewportHeight - fittedH) / 2.0;

  final double cx = viewportWidth / 2.0;
  final double cy = viewportHeight / 2.0;
  final double tx = cx - zoom * cx + dx;
  final double ty = cy - zoom * cy + dy;

  final Matrix4 transform = Matrix4.identity()
    ..translateByDouble(tx, ty, 0.0, 1.0)
    ..scaleByDouble(zoom, zoom, 1.0, 1.0);
  final Matrix4 inv = Matrix4.inverted(transform);

  final int outW = math.max(640, math.min((viewportWidth * 1.5).round(), 1080));
  final int outH = (outW * (viewportHeight / viewportWidth)).round().clamp(200, 1080);
  final outImg = img.Image(width: outW, height: outH);

  final double invScaleX = inv.storage[0];
  final double invTransX = inv.storage[12];
  final double invScaleY = inv.storage[5];
  final double invTransY = inv.storage[13];

  for (int y = 0; y < outH; y++) {
    final double vpY = (y / outH) * viewportHeight;
    final double childY = invScaleY * vpY + invTransY;
    final double imgY = (childY - offsetY) / scaleFit;
    final int srcYInt = imgY.round().clamp(0, srcImg.height - 1);

    for (int x = 0; x < outW; x++) {
      final double vpX = (x / outW) * viewportWidth;
      final double childX = invScaleX * vpX + invTransX;
      final double imgX = (childX - offsetX) / scaleFit;
      final int srcXInt = imgX.round().clamp(0, srcImg.width - 1);

      outImg.setPixel(x, y, srcImg.getPixel(srcXInt, srcYInt));
    }
  }

  return Uint8List.fromList(img.encodePng(outImg));
}

/// Computes the expected normalized guide X position [0..1] for a source image X coordinate
double expectedGuideNormX({
  required double srcBandX,
  required int srcW,
  required int srcH,
  required double zoom,
  required double dx,
  required double viewportWidth,
  required double viewportHeight,
}) {
  final double scaleFit = math.min(viewportWidth / srcW, viewportHeight / srcH);
  final double fittedW = srcW * scaleFit;
  final double offsetX = (viewportWidth - fittedW) / 2.0;
  final double cx = viewportWidth / 2.0;
  final double tx = cx - zoom * cx + dx;

  final double childX = offsetX + srcBandX * scaleFit;
  final double vpX = zoom * childX + tx;
  final double guideLeft = viewportWidth * 0.20;
  final double guideWidth = viewportWidth * 0.60;
  return ((vpX - guideLeft) / guideWidth).clamp(0.04, 0.96);
}

void main() {
  group('Multi-Scale Zoom & Pan Wireframe Alignment Verification', () {
    test('Real resistor photo across 10 zoom, pan, and orientation scenarios', () {
      final file = File(r'C:\Users\spjen\Downloads\resistor.webp');
      if (!file.existsSync()) {
        return;
      }
      final rawBytes = file.readAsBytesSync();
      final srcImg = img.decodeImage(rawBytes)!;
      final flippedImg = img.flipHorizontal(srcImg.clone());

      // True band centers in resistor.webp (474x355 source coordinates):
      // Brown=307.2, Black=255.7, Orange=208.1, Gold=161.2
      const List<double> trueSrcBands = [307.2, 255.7, 208.1, 161.2];
      final List<double> trueFlippedBands =
          trueSrcBands.map((x) => (srcImg.width - 1) - x).toList();

      const double vpW = 480.0;
      const double vpH = 290.0;

      final scenarios = [
        (name: '1. Zoom 1.0x', zoom: 1.0, dx: 0.0, dy: 0.0, flip: false),
        (name: '2. Zoom 1.3x', zoom: 1.3, dx: 0.0, dy: 0.0, flip: false),
        (name: '3. Zoom 1.69x', zoom: 1.69, dx: 0.0, dy: 0.0, flip: false),
        (name: '4. Zoom 2.2x', zoom: 2.2, dx: 0.0, dy: 0.0, flip: false),
        (name: '5. Zoom 0.8x', zoom: 0.8, dx: 0.0, dy: 0.0, flip: false),
        (name: '6. Zoom 1.56x pan L+D', zoom: 1.56, dx: -35.0, dy: 18.0, flip: false),
        (name: '7. Zoom 1.69x pan R+U', zoom: 1.69, dx: 40.0, dy: -20.0, flip: false),
        (name: '8. Flipped 1.0x', zoom: 1.0, dx: 0.0, dy: 0.0, flip: true),
        (name: '9. Flipped 1.8x pan', zoom: 1.8, dx: -25.0, dy: 12.0, flip: true),
      ];

      for (final s in scenarios) {
        final activeImg = s.flip ? flippedImg : srcImg;
        final pngBytes = extractTransformedRegion(
          srcImg: activeImg,
          zoom: s.zoom,
          dx: s.dx,
          dy: s.dy,
          viewportWidth: vpW,
          viewportHeight: vpH,
        );

        final bool isRev = OpticalStripeDetector.detectIsReversed(
          pngBytes,
          4,
          viewportWidth: vpW,
          viewportHeight: vpH,
        );
        expect(isRev, equals(!s.flip), reason: '${s.name} orientation mismatch');

        final List<double>? norms = OpticalStripeDetector.detectStripes(
          pngBytes,
          4,
          viewportWidth: vpW,
          viewportHeight: vpH,
          isReversed: isRev,
        );
        expect(norms, isNotNull, reason: '${s.name} returned null stripes');
        expect(norms!.length, equals(4), reason: '${s.name} band count != 4');

        final expectedSrc = s.flip ? trueFlippedBands : trueSrcBands;
        for (int i = 0; i < 4; i++) {
          final double expNorm = expectedGuideNormX(
            srcBandX: expectedSrc[i],
            srcW: activeImg.width,
            srcH: activeImg.height,
            zoom: s.zoom,
            dx: s.dx,
            viewportWidth: vpW,
            viewportHeight: vpH,
          );
          expect(
            (norms[i] - expNorm).abs(),
            lessThan(0.028),
            reason:
                '${s.name} Band ${i + 1}: detected=${norms[i].toStringAsFixed(3)} vs expected=${expNorm.toStringAsFixed(3)}',
          );
        }
      }
    });

    testWidgets('InteractiveBandOverlay renders locked wireframes and updates on zoom',
        (WidgetTester tester) async {
      final file = File(r'C:\Users\spjen\Downloads\resistor.webp');
      if (!file.existsSync()) return;
      final srcImg = img.decodeImage(file.readAsBytesSync())!;

      final bytes1x = extractTransformedRegion(
        srcImg: srcImg,
        zoom: 1.0,
        dx: 0.0,
        dy: 0.0,
        viewportWidth: 480.0,
        viewportHeight: 290.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 480.0,
              height: 290.0,
              child: InteractiveBandOverlay(
                bandCount: 4,
                band1Index: 1, // Brown
                band2Index: 0, // Black
                band3Index: 3, // Orange
                band4Index: 6, // Gold
                band5Index: 0,
                band6Index: 0,
                onBandColorChanged: (_, _) {},
                viewportWidth: 480.0,
                viewportHeight: 290.0,
                capturedImageBytes: bytes1x,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ALIGN'), findsOneWidget);
    });
  });
}
