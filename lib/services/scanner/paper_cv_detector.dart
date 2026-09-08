import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'scanner_models.dart';

class PaperCvDetector {
  static const String sourceName = "PAPER_CV";

  static BandColor _codeToColor(int code) {
    switch (code) {
      case 0: return BandColor.black;
      case 1: return BandColor.brown;
      case 2: return BandColor.red;
      case 3: return BandColor.orange;
      case 4: return BandColor.yellow;
      case 5: return BandColor.green;
      case 6: return BandColor.blue;
      case 7: return BandColor.violet;
      case 8: return BandColor.grey;
      case 9: return BandColor.white;
      case 10: return BandColor.gold;
      case 11: return BandColor.silver;
      default: return BandColor.none;
    }
  }

  static Future<RecognitionCandidate> detect(Uint8List imageBytes) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null || image.width < 30 || image.height < 30) {
        return RecognitionCandidate(success: false, source: sourceName, errorMessage: "Invalid image.");
      }

      final roiLeft = (image.width * 0.15).toInt();
      final roiRight = (image.width * 0.85).toInt();
      final roiTop = (image.height * 0.30).toInt();
      final roiBottom = (image.height * 0.70).toInt();
      final roiWidth = roiRight - roiLeft;
      final roiHeight = roiBottom - roiTop;

      if (roiWidth < 20 || roiHeight < 8) {
        return RecognitionCandidate(success: false, source: sourceName, errorMessage: "ROI too small.");
      }

      img.Image workImg = img.copyCrop(image, x: roiLeft, y: roiTop, width: roiWidth, height: roiHeight);

      // Step 1: Contrast enhancement & White balance (simplified)
      // Enhance contrast so background becomes light/uniform
      double avgR = 0, avgG = 0, avgB = 0;
      for (int y = 0; y < workImg.height; y++) {
        for (int x = 0; x < workImg.width; x++) {
          final p = workImg.getPixel(x, y);
          avgR += p.r; avgG += p.g; avgB += p.b;
        }
      }
      int totalPx = workImg.width * workImg.height;
      avgR /= totalPx; avgG /= totalPx; avgB /= totalPx;
      double avgAll = (avgR + avgG + avgB) / 3.0;
      double scaleR = avgAll / (avgR + 1);
      double scaleG = avgAll / (avgG + 1);
      double scaleB = avgAll / (avgB + 1);

      img.Image balanced = img.Image(width: workImg.width, height: workImg.height);
      for (int y = 0; y < workImg.height; y++) {
        for (int x = 0; x < workImg.width; x++) {
          final p = workImg.getPixel(x, y);
          int r = (p.r * scaleR).clamp(0, 255).toInt();
          int g = (p.g * scaleG).clamp(0, 255).toInt();
          int b = (p.b * scaleB).clamp(0, 255).toInt();
          balanced.setPixelRgb(x, y, r, g, b);
        }
      }

      // Step 6 & 7: Contour detection & Rotated Bounding Rectangle
      // Using Image Moments to find elongated resistor geometry
      double sumX = 0, sumY = 0;
      int objCount = 0;
      for (int y = 0; y < balanced.height; y++) {
        for (int x = 0; x < balanced.width; x++) {
          final p = balanced.getPixel(x, y);
          int r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
          int maxDiff = math.max(math.max((r-g).abs(), (r-b).abs()), (g-b).abs());
          // Adaptive thresholding approximation
          if (maxDiff > 25 || (r<120 && g<120 && b<120)) {
            sumX += x; sumY += y; objCount++;
          }
        }
      }

      if (objCount < balanced.width * balanced.height * 0.05) {
         return RecognitionCandidate(success: false, isResistor: false, source: sourceName, errorMessage: "No resistor-like object found.");
      }

      double cx = sumX / objCount;
      double cy = sumY / objCount;
      double m20 = 0, m02 = 0, m11 = 0;
      for (int y = 0; y < balanced.height; y++) {
        for (int x = 0; x < balanced.width; x++) {
          final p = balanced.getPixel(x, y);
          int r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
          int maxDiff = math.max(math.max((r-g).abs(), (r-b).abs()), (g-b).abs());
          if (maxDiff > 25 || (r<120 && g<120 && b<120)) {
            double dx = x - cx;
            double dy = y - cy;
            m20 += dx * dx;
            m02 += dy * dy;
            m11 += dx * dy;
          }
        }
      }

      double theta = 0.5 * math.atan2(2 * m11, m20 - m02);
      if (theta > 0.3) theta = 0.3;
      if (theta < -0.3) theta = -0.3;

      // Aspect ratio check for "elongated resistor-like geometry"
      double lambda1 = 0.5 * (m20 + m02 + math.sqrt(4 * m11 * m11 + (m20 - m02) * (m20 - m02)));
      double lambda2 = 0.5 * (m20 + m02 - math.sqrt(4 * m11 * m11 + (m20 - m02) * (m20 - m02)));
      if (lambda1 / (lambda2 + 1) < 1.5) {
         return RecognitionCandidate(success: false, isResistor: false, source: sourceName, errorMessage: "Not elongated enough.");
      }

      // Step 8: Resistor rotation/alignment (extract profile along axis)
      List<List<int>> profile = List.generate(balanced.width, (_) => [0, 0, 0]);
      int deltaY = (balanced.height * 0.08).toInt();
      if (deltaY < 2) deltaY = 2;

      List<List<int>> bodyPixels = [];
      for (int x = 0; x < balanced.width; x++) {
        double yAxis = cy + (x - cx) * math.tan(theta);
        int sumR=0, sumG=0, sumB=0;
        int c=0;
        for (int dy = -deltaY; dy <= deltaY; dy++) {
          int y = (yAxis + dy).round();
          if (y >= 0 && y < balanced.height) {
            final p = balanced.getPixel(x, y);
            sumR += p.r.toInt(); sumG += p.g.toInt(); sumB += p.b.toInt();
            c++;
            bodyPixels.add([p.r.toInt(), p.g.toInt(), p.b.toInt()]);
          }
        }
        if (c > 0) profile[x] = [sumR~/c, sumG~/c, sumB~/c];
      }

      // Step 9 & 10: K-means color clustering & Body-color estimation
      // Simplified: Find the most frequent color bin
      Map<int, int> colorBins = {};
      for (var px in bodyPixels) {
         int binR = px[0] ~/ 32;
         int binG = px[1] ~/ 32;
         int binB = px[2] ~/ 32;
         int bin = (binR << 16) | (binG << 8) | binB;
         colorBins[bin] = (colorBins[bin] ?? 0) + 1;
      }
      int maxBin = -1, maxCount = -1;
      colorBins.forEach((bin, c) {
        if (c > maxCount) { maxCount = c; maxBin = bin; }
      });
      int bodyR = ((maxBin >> 16) & 0xFF) * 32 + 16;
      int bodyG = ((maxBin >> 8) & 0xFF) * 32 + 16;
      int bodyB = (maxBin & 0xFF) * 32 + 16;

      // Ensure body is light enough, if it clustered to a dark band, pick next
      if (bodyR < 100 && bodyG < 100 && bodyB < 100) {
         bodyR = 190; bodyG = 160; bodyB = 140; // Fallback
      }

      // Step 13: SSD-based band position detection
      List<double> ssd = List.filled(balanced.width, 0.0);
      for (int x = 0; x < balanced.width; x++) {
         double dr = (profile[x][0] - bodyR).toDouble();
         double dg = (profile[x][1] - bodyG).toDouble();
         double db = (profile[x][2] - bodyB).toDouble();
         ssd[x] = math.sqrt(dr*dr + dg*dg + db*db);
      }

      // Detect peaks/runs where SSD > threshold
      List<DetectedBand> rawCandidates = [];
      int runStart = -1;
      for (int x = 0; x < balanced.width; x++) {
         if (ssd[x] > 60.0) { // Significant deviation from body
            if (runStart == -1) runStart = x;
         } else {
            if (runStart != -1) {
               if (x - runStart >= balanced.width * 0.03 && runStart > (balanced.width * 0.05)) {
                  // Found a band region
                  int bandW = x - runStart;
                  int bandMid = runStart + bandW ~/ 2;
                  int avgR = 0, avgG = 0, avgB = 0;
                  for (int bx = runStart; bx < x; bx++) {
                     avgR += profile[bx][0]; avgG += profile[bx][1]; avgB += profile[bx][2];
                  }
                  avgR ~/= bandW; avgG ~/= bandW; avgB ~/= bandW;
                  
                  // Step 14: Reference-color matching
                  final List<_RefColor> refs = [
                    _RefColor(0, 40, 40, 40),
                    _RefColor(1, 110, 70, 50),
                    _RefColor(2, 200, 50, 50),
                    _RefColor(3, 230, 110, 30),
                    _RefColor(4, 240, 200, 40),
                    _RefColor(5, 60, 150, 70),
                    _RefColor(6, 40, 100, 180),
                    _RefColor(7, 130, 50, 150),
                    _RefColor(8, 130, 130, 130),
                    _RefColor(9, 220, 220, 220),
                    _RefColor(10, 180, 140, 60),
                    _RefColor(11, 170, 170, 170),
                  ];
                  
                  int bestCode = -1;
                  double minDist = 99999;
                  for (var ref in refs) {
                     double d = math.sqrt(math.pow(avgR - ref.r, 2) + math.pow(avgG - ref.g, 2) + math.pow(avgB - ref.b, 2));
                     if (d < minDist) { minDist = d; bestCode = ref.code; }
                  }

                  if (bestCode >= 0 && minDist < 120.0) {
                     rawCandidates.add(DetectedBand(
                        color: _codeToColor(bestCode),
                        axisPosition: bandMid / balanced.width,
                        startPosition: runStart / balanced.width,
                        endPosition: x / balanced.width,
                        width: bandW / balanced.width,
                        confidence: math.max(0.0, 1.0 - (minDist / 120.0)),
                     ));
                  }
               }
               runStart = -1;
            }
         }
      }

      if (rawCandidates.length < 4 || rawCandidates.length > 6) {
        return RecognitionCandidate(success: false, source: sourceName, errorMessage: "Found ${rawCandidates.length} bands.");
      }

      return RecognitionCandidate(
        success: true,
        isResistor: true,
        bandCount: rawCandidates.length,
        bands: rawCandidates,
        overallConfidence: rawCandidates.map((b) => b.confidence).reduce((a, b) => a + b) / rawCandidates.length,
        source: sourceName,
      );

    } catch (e) {
      return RecognitionCandidate(success: false, source: sourceName, errorMessage: e.toString());
    }
  }
}

class _RefColor {
  final int code;
  final int r;
  final int g;
  final int b;
  _RefColor(this.code, this.r, this.g, this.b);
}
