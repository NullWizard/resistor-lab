import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'scanner_models.dart';

class CenterlineDetector {
  static const String sourceName = "CENTERLINE";

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
        return RecognitionCandidate(success: false, source: sourceName, errorMessage: "Invalid image size.");
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

      final img.Image roi = img.copyCrop(image, x: roiLeft, y: roiTop, width: roiWidth, height: roiHeight);

      // Moment-based axis estimation
      double sumX = 0, sumY = 0;
      int count = 0;
      for (int y = 0; y < roi.height; y++) {
        for (int x = 0; x < roi.width; x++) {
          final p = roi.getPixel(x, y);
          int r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
          int maxDiff = math.max(math.max((r-g).abs(), (r-b).abs()), (g-b).abs());
          if (maxDiff > 30 || (r<100 && g<100 && b<100)) {
            sumX += x; sumY += y; count++;
          }
        }
      }
      double cx = roi.width / 2.0;
      double cy = roi.height / 2.0;
      double theta = 0;
      if (count >= 10) {
        cx = sumX / count;
        cy = sumY / count;
        double m20 = 0, m02 = 0, m11 = 0;
        for (int y = 0; y < roi.height; y++) {
          for (int x = 0; x < roi.width; x++) {
            final p = roi.getPixel(x, y);
            int r = p.r.toInt(), g = p.g.toInt(), b = p.b.toInt();
            int maxDiff = math.max(math.max((r-g).abs(), (r-b).abs()), (g-b).abs());
            if (maxDiff > 30 || (r<100 && g<100 && b<100)) {
              double dx = x - cx;
              double dy = y - cy;
              m20 += dx * dx;
              m02 += dy * dy;
              m11 += dx * dy;
            }
          }
        }
        theta = 0.5 * math.atan2(2 * m11, m20 - m02);
        if (theta > 0.26) theta = 0.26;
        if (theta < -0.26) theta = -0.26;
      }

      List<List<double>> profile = List.generate(roi.width, (_) => [0.0, 0.0, 0.0]);
      int deltaY = (roi.height * 0.06).toInt();
      if (deltaY < 1) deltaY = 1;

      for (int x = 0; x < roi.width; x++) {
        double yAxis = cy + (x - cx) * math.tan(theta);
        List<List<double>> labs = [];
        for (int dy = -deltaY; dy <= deltaY; dy++) {
          int y = (yAxis + dy).round();
          if (y >= 0 && y < roi.height) {
            final p = roi.getPixel(x, y);
            labs.add(_rgbToLab(p.r.toInt(), p.g.toInt(), p.b.toInt()));
          }
        }
        if (labs.isNotEmpty) {
          labs.sort((a, b) => a[0].compareTo(b[0]));
          int trim = (labs.length * 0.2).toInt();
          double sumL = 0, sumA = 0, sumB = 0;
          int c = 0;
          for (int i = trim; i < labs.length - trim; i++) {
            sumL += labs[i][0]; sumA += labs[i][1]; sumB += labs[i][2];
            c++;
          }
          profile[x] = c > 0 ? [sumL/c, sumA/c, sumB/c] : labs[0];
        }
      }

      int smoothW = (roi.width * 0.015).toInt();
      if (smoothW < 1) smoothW = 1;
      List<List<double>> smoothed = List.generate(roi.width, (_) => [0.0, 0.0, 0.0]);
      for (int x = 0; x < roi.width; x++) {
        double sl = 0, sa = 0, sb = 0;
        int sc = 0;
        for (int dx = -smoothW; dx <= smoothW; dx++) {
          int px = x + dx;
          if (px >= 0 && px < roi.width) {
            sl += profile[px][0]; sa += profile[px][1]; sb += profile[px][2];
            sc++;
          }
        }
        smoothed[x] = [sl/sc, sa/sc, sb/sc];
      }

      final List<_LabColorRef> refs = [
        _LabColorRef(0, 'Black', 40, 40, 40),
        _LabColorRef(1, 'Brown', 110, 70, 50),
        _LabColorRef(2, 'Red', 200, 50, 50),
        _LabColorRef(3, 'Orange', 230, 110, 30),
        _LabColorRef(4, 'Yellow', 240, 200, 40),
        _LabColorRef(5, 'Green', 60, 150, 70),
        _LabColorRef(6, 'Blue', 40, 100, 180),
        _LabColorRef(7, 'Violet', 130, 50, 150),
        _LabColorRef(8, 'Grey', 130, 130, 130),
        _LabColorRef(9, 'White', 220, 220, 220),
        _LabColorRef(10, 'Gold', 180, 140, 60),
        _LabColorRef(11, 'Silver', 170, 170, 170),
        _LabColorRef(-1, 'CeramicBody1', 190, 160, 140),
        _LabColorRef(-1, 'CeramicBody2', 222, 202, 172),
        _LabColorRef(-1, 'CeramicBody3', 100, 180, 200),
        _LabColorRef(-2, 'Background', 20, 20, 20),
        _LabColorRef(-2, 'WhiteBg', 255, 255, 255),
      ];

      List<DetectedBand> rawCandidates = [];
      int currentCode = -99;
      int runStart = 0;
      double minRunDist = 999;

      for (int x = 0; x < roi.width; x++) {
        double minDist = 999999;
        int bestCode = -2;
        for (var ref in refs) {
          double d = _colorDistanceLab(smoothed[x], ref.lab, weightL: 0.5);
          if (d < minDist) { minDist = d; bestCode = ref.code; }
        }
        
        if (bestCode >= 0 && minDist < 100.0) {
          if (bestCode != currentCode) {
            if (currentCode >= 0 && (x - runStart) >= roi.width * 0.035) {
               rawCandidates.add(DetectedBand(
                  color: _codeToColor(currentCode),
                  axisPosition: (runStart + x - 1) / 2.0 / roi.width,
                  startPosition: runStart / roi.width,
                  endPosition: (x - 1) / roi.width,
                  width: (x - runStart) / roi.width,
                  confidence: math.max(0.0, 1.0 - (minRunDist / 100.0)),
               ));
            }
            currentCode = bestCode;
            runStart = x;
            minRunDist = minDist;
          } else {
            if (minDist < minRunDist) minRunDist = minDist;
          }
        } else {
          if (currentCode >= 0 && (x - runStart) >= roi.width * 0.035) {
             rawCandidates.add(DetectedBand(
                  color: _codeToColor(currentCode),
                  axisPosition: (runStart + x - 1) / 2.0 / roi.width,
                  startPosition: runStart / roi.width,
                  endPosition: (x - 1) / roi.width,
                  width: (x - runStart) / roi.width,
                  confidence: math.max(0.0, 1.0 - (minRunDist / 100.0)),
             ));
          }
          currentCode = -99;
        }
      }
      if (currentCode >= 0 && (roi.width - runStart) >= roi.width * 0.035) {
         rawCandidates.add(DetectedBand(
                  color: _codeToColor(currentCode),
                  axisPosition: (runStart + roi.width - 1) / 2.0 / roi.width,
                  startPosition: runStart / roi.width,
                  endPosition: (roi.width - 1) / roi.width,
                  width: (roi.width - runStart) / roi.width,
                  confidence: math.max(0.0, 1.0 - (minRunDist / 100.0)),
         ));
      }

      List<DetectedBand> merged = [];
      for (var c in rawCandidates) {
        if (merged.isNotEmpty && merged.last.color == c.color) {
          if (c.startPosition - merged.last.endPosition < 0.05) {
            final last = merged.last;
            merged[merged.length - 1] = DetectedBand(
              color: c.color,
              axisPosition: (last.axisPosition * last.width + c.axisPosition * c.width) / (last.width + c.width),
              startPosition: last.startPosition,
              endPosition: c.endPosition,
              width: c.endPosition - last.startPosition,
              confidence: (last.confidence + c.confidence) / 2,
            );
            continue;
          }
        }
        merged.add(c);
      }

      if (merged.length < 4 || merged.length > 6) {
        return RecognitionCandidate(success: false, source: sourceName, errorMessage: "Found ${merged.length} bands.");
      }

      return RecognitionCandidate(
        success: true,
        isResistor: true,
        bandCount: merged.length,
        bands: merged,
        overallConfidence: merged.map((b) => b.confidence).reduce((a, b) => a + b) / merged.length,
        source: sourceName,
      );
    } catch (e) {
      return RecognitionCandidate(success: false, source: sourceName, errorMessage: e.toString());
    }
  }

  static List<double> _rgbToLab(int r, int g, int b) {
    double rf = r / 255.0;
    double gf = g / 255.0;
    double bf = b / 255.0;
    rf = rf > 0.04045 ? math.pow((rf + 0.055) / 1.055, 2.4).toDouble() : rf / 12.92;
    gf = gf > 0.04045 ? math.pow((gf + 0.055) / 1.055, 2.4).toDouble() : gf / 12.92;
    bf = bf > 0.04045 ? math.pow((bf + 0.055) / 1.055, 2.4).toDouble() : bf / 12.92;
    double x = (rf * 0.4124 + gf * 0.3576 + bf * 0.1805) * 100.0;
    double y = (rf * 0.2126 + gf * 0.7152 + bf * 0.0722) * 100.0;
    double z = (rf * 0.0193 + gf * 0.1192 + bf * 0.9505) * 100.0;
    double xn = 95.047;
    double yn = 100.000;
    double zn = 108.883;
    double fx = _labToXyz(x / xn);
    double fy = _labToXyz(y / yn);
    double fz = _labToXyz(z / zn);
    double l = (116.0 * fy) - 16.0;
    double a = 500.0 * (fx - fy);
    double bVal = 200.0 * (fy - fz);
    return [l, a, bVal];
  }

  static double _labToXyz(double t) {
    return t > 0.008856 ? math.pow(t, 1.0/3.0).toDouble() : (7.787 * t) + (16.0 / 116.0);
  }

  static double _colorDistanceLab(List<double> lab1, List<double> lab2, {double weightL = 1.0}) {
    double dl = (lab1[0] - lab2[0]) * weightL;
    double da = lab1[1] - lab2[1];
    double db = lab1[2] - lab2[2];
    return math.sqrt(dl * dl + da * da + db * db);
  }
}

class _LabColorRef {
  final int code;
  final String name;
  final List<double> lab;
  _LabColorRef(this.code, this.name, int r, int g, int b) : lab = CenterlineDetector._rgbToLab(r, g, b);
}
