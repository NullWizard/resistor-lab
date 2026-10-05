import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import '../services/resistor_scanner_service.dart';

/// Data model representing a color choice with probability ranking.
class BandColorOption {
  final int index;
  final String name;
  final Color color;
  final String valueLabel;
  final double probabilityScore;
  final String reasonLabel;
  final bool isCurrent;

  const BandColorOption({
    required this.index,
    required this.name,
    required this.color,
    required this.valueLabel,
    required this.probabilityScore,
    required this.reasonLabel,
    this.isCurrent = false,
  });
}

/// Helper calculating most probable colors vs other colors for any band position.
class BandProbabilityHelper {
  static const Map<String, List<String>> _visualConfusionMap = {
    'Brown': ['Red', 'Orange', 'Black', 'Gold'],
    'Red': ['Brown', 'Orange'],
    'Orange': ['Red', 'Yellow', 'Brown'],
    'Yellow': ['Orange', 'Gold', 'White'],
    'Green': ['Blue'],
    'Blue': ['Violet', 'Green', 'Black'],
    'Violet': ['Blue', 'Grey', 'Black'],
    'Grey': ['Silver', 'White', 'Violet'],
    'White': ['Grey', 'Yellow'],
    'Black': ['Brown', 'Blue', 'Violet'],
    'Gold': ['Yellow', 'Brown', 'Orange'],
    'Silver': ['Grey', 'White'],
  };

  static BandProbabilityResult getOptionsForBand({
    required int bandIndex,
    required int bandCount,
    required int currentValue,
  }) {
    String bandTitle = 'Band ${bandIndex + 1}';
    String roleDescription = '';
    final List<BandColorOption> allOptions = [];

    final bool is4Band = bandCount == 4;
    final bool isDigit = bandIndex == 0 || bandIndex == 1 || (!is4Band && bandIndex == 2);
    final bool isMultiplier = (is4Band && bandIndex == 2) || (!is4Band && bandIndex == 3);
    final bool isTolerance = (is4Band && bandIndex == 3) || (!is4Band && bandIndex == 4);
    final bool isTempCo = !is4Band && bandIndex == 5;

    if (isDigit) {
      if (bandIndex == 0) {
        bandTitle = 'Band 1 (1st Digit)';
        roleDescription = 'First Significant Digit';
      } else if (bandIndex == 1) {
        bandTitle = 'Band 2 (2nd Digit)';
        roleDescription = 'Second Significant Digit';
      } else {
        bandTitle = 'Band 3 (3rd Digit)';
        roleDescription = 'Third Significant Digit (Precision)';
      }

      final currentColorName = ResistorScannerService.digitColors[currentValue.clamp(0, 9)].name;
      final confusions = _visualConfusionMap[currentColorName] ?? [];
      const common1stDigits = ['Brown', 'Red', 'Orange', 'Yellow', 'Green', 'Blue'];
      const commonOtherDigits = ['Black', 'Brown', 'Red', 'Orange', 'Yellow', 'Violet'];

      for (int i = 0; i < ResistorScannerService.digitColors.length; i++) {
        final b = ResistorScannerService.digitColors[i];
        final bool isCur = i == currentValue;
        double score = 0.35;
        String reason = 'Standard Digit Option';

        if (isCur) {
          score = 1.0;
          reason = 'Currently Selected / Detected';
        } else if (confusions.contains(b.name)) {
          score = 0.85;
          reason = 'Optical Match / Common Lighting Confusion';
        } else if (bandIndex == 0 && common1stDigits.contains(b.name)) {
          score = 0.75;
          reason = 'Common E24 1st Digit';
        } else if (bandIndex > 0 && commonOtherDigits.contains(b.name)) {
          score = 0.72;
          reason = 'Common Value in E-Series';
        } else if (bandIndex == 0 && b.name == 'Black') {
          score = 0.15;
          reason = 'Rare (No Leading Zero in Axial Resistors)';
        }

        allOptions.add(BandColorOption(
          index: i,
          name: b.name,
          color: b.color,
          valueLabel: 'Digit: ${b.value}',
          probabilityScore: score,
          reasonLabel: reason,
          isCurrent: isCur,
        ));
      }
    } else if (isMultiplier) {
      bandTitle = is4Band ? 'Band 3 (Multiplier)' : 'Band 4 (Multiplier)';
      roleDescription = 'Resistance Decade Multiplier';

      final currentColorName = ResistorScannerService.multiplierColors[currentValue.clamp(0, ResistorScannerService.multiplierColors.length - 1)].name;
      final confusions = _visualConfusionMap[currentColorName] ?? [];
      const commonMultipliers = ['Black', 'Brown', 'Red', 'Orange', 'Yellow', 'Gold'];

      for (int i = 0; i < ResistorScannerService.multiplierColors.length; i++) {
        final b = ResistorScannerService.multiplierColors[i];
        final bool isCur = i == currentValue;
        double score = 0.35;
        String reason = 'High Multiplier Option';

        String multStr = '×${_formatMultiplierNumber(b.multiplier)}';

        if (isCur) {
          score = 1.0;
          reason = 'Currently Selected / Detected';
        } else if (confusions.contains(b.name)) {
          score = 0.86;
          reason = 'Optical Match / Common Lighting Confusion';
        } else if (commonMultipliers.contains(b.name)) {
          score = 0.78;
          reason = 'Standard Commercial Decade ($multStr)';
        }

        allOptions.add(BandColorOption(
          index: i,
          name: b.name,
          color: b.color,
          valueLabel: 'Multiplier: $multStr',
          probabilityScore: score,
          reasonLabel: reason,
          isCurrent: isCur,
        ));
      }
    } else if (isTolerance) {
      bandTitle = is4Band ? 'Band 4 (Tolerance)' : 'Band 5 (Tolerance)';
      roleDescription = 'Tolerance Rating (Accuracy)';

      for (int i = 0; i < ResistorScannerService.toleranceColors.length; i++) {
        final b = ResistorScannerService.toleranceColors[i];
        final bool isCur = i == currentValue;
        double score = 0.30;
        String reason = 'Precision Laboratory Grade';

        if (isCur) {
          score = 1.0;
          reason = 'Currently Selected / Detected';
        } else if (b.name == 'Gold') {
          score = 0.94;
          reason = 'Standard Commercial (±5% - 70% of Resistors)';
        } else if (b.name == 'Brown') {
          score = 0.88;
          reason = 'Standard Precision (±1% - 25% of Resistors)';
        } else if (b.name == 'Red') {
          score = 0.76;
          reason = 'Semi-Precision (±2%)';
        } else if (b.name == 'Silver') {
          score = 0.70;
          reason = 'Wide Tolerance (±10%)';
        }

        allOptions.add(BandColorOption(
          index: i,
          name: b.name,
          color: b.color,
          valueLabel: 'Tolerance: ±${b.tolerance}%',
          probabilityScore: score,
          reasonLabel: reason,
          isCurrent: isCur,
        ));
      }
    } else if (isTempCo) {
      bandTitle = 'Band 6 (Temp. Coefficient)';
      roleDescription = 'Temperature Coefficient Rating (ppm/K)';

      for (int i = 0; i < ResistorScannerService.tempCoColors.length; i++) {
        final b = ResistorScannerService.tempCoColors[i];
        final bool isCur = i == currentValue;
        double score = 0.40;
        String reason = 'Specialist PPM Rating';

        if (isCur) {
          score = 1.0;
          reason = 'Currently Selected / Detected';
        } else if (b.name == 'Brown') {
          score = 0.90;
          reason = 'Standard 100 ppm/K (75% of 6-Band Resistors)';
        } else if (b.name == 'Red') {
          score = 0.84;
          reason = 'High Stability 50 ppm/K';
        } else if (b.name == 'Orange') {
          score = 0.72;
          reason = 'Precision 15 ppm/K';
        }

        allOptions.add(BandColorOption(
          index: i,
          name: b.name,
          color: b.color,
          valueLabel: 'Coeff: ${b.value} ppm/K',
          probabilityScore: score,
          reasonLabel: reason,
          isCurrent: isCur,
        ));
      }
    }

    // Split into Most Probable vs Other Options
    final mostProbable = allOptions.where((opt) => opt.probabilityScore >= 0.70).toList();
    final otherOptions = allOptions.where((opt) => opt.probabilityScore < 0.70).toList();

    // Sort most probable by probability score descending (current item first)
    mostProbable.sort((a, b) {
      if (a.isCurrent) return -1;
      if (b.isCurrent) return 1;
      return b.probabilityScore.compareTo(a.probabilityScore);
    });

    return BandProbabilityResult(
      bandTitle: bandTitle,
      roleDescription: roleDescription,
      mostProbable: mostProbable,
      otherOptions: otherOptions,
    );
  }

  static String _formatMultiplierNumber(double m) {
    if (m >= 1e9) return '${(m / 1e9).toStringAsFixed(0)}G';
    if (m >= 1e6) return '${(m / 1e6).toStringAsFixed(0)}M';
    if (m >= 1e3) return '${(m / 1e3).toStringAsFixed(0)}k';
    if (m == 0.1) return '0.1';
    if (m == 0.01) return '0.01';
    return m.toStringAsFixed(0);
  }
}

class BandProbabilityResult {
  final String bandTitle;
  final String roleDescription;
  final List<BandColorOption> mostProbable;
  final List<BandColorOption> otherOptions;

  const BandProbabilityResult({
    required this.bandTitle,
    required this.roleDescription,
    required this.mostProbable,
    required this.otherOptions,
  });
}

/// Optical stripe detector scanning the real image pixels for resistor band peaks.
class OpticalStripeDetector {
  static List<double>? detectStripes(
    Uint8List? imageBytes,
    int bandCount, {
    double? viewportWidth,
    double? viewportHeight,
    bool isReversed = false,
  }) {
    if (imageBytes == null || imageBytes.isEmpty) return null;
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null || decoded.width < 50 || decoded.height < 30) return null;

      final int w = decoded.width;
      final int h = decoded.height;

      // Guide box region in image coordinates accounting for BoxFit.cover
      int gLeft, gRight, gTop, gBottom;
      if (viewportWidth != null && viewportHeight != null && viewportWidth > 0 && viewportHeight > 0) {
        final double scale = math.max(viewportWidth / w, viewportHeight / h);
        final double renderedW = w * scale;
        final double renderedH = h * scale;
        final double cropX = (renderedW - viewportWidth) / 2.0;
        final double cropY = (renderedH - viewportHeight) / 2.0;
        final double guideViewLeft = viewportWidth * 0.20;
        final double guideViewRight = viewportWidth * 0.80;
        final double guideViewTop = viewportHeight * 0.35;
        final double guideViewBottom = viewportHeight * 0.65;
        gLeft = ((guideViewLeft + cropX) / scale).clamp(0.0, w - 1.0).round();
        gRight = ((guideViewRight + cropX) / scale).clamp(0.0, w - 1.0).round();
        gTop = ((guideViewTop + cropY) / scale).clamp(0.0, h - 1.0).round();
        gBottom = ((guideViewBottom + cropY) / scale).clamp(0.0, h - 1.0).round();
      } else {
        gLeft = (w * 0.20).round();
        gRight = (w * 0.80).round();
        gTop = (h * 0.35).round();
        gBottom = (h * 0.65).round();
      }

      final int gWidth = gRight - gLeft;
      final int gHeight = gBottom - gTop;
      if (gWidth < 40 || gHeight < 10) return null;

      // Multi-slice horizontal strip across the resistor body (central 50% of guide height)
      final int yMin = (gTop + gHeight * 0.25).round().clamp(0, h - 1);
      final int yMax = (gTop + gHeight * 0.75).round().clamp(0, h - 1);

      // Compute average column RGB profile across the vertical slice
      final List<List<double>> colColors = [];
      for (int x = gLeft; x < gRight; x++) {
        double rSum = 0, gSum = 0, bSum = 0;
        int count = 0;
        for (int y = yMin; y <= yMax; y++) {
          final p = decoded.getPixel(x, y);
          rSum += p.r;
          gSum += p.g;
          bSum += p.b;
          count++;
        }
        colColors.add([rSum / count, gSum / count, bSum / count]);
      }

      // Estimate background ceramic body color (median color along the strip)
      final List<double> lumList = colColors
          .map((c) => 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2])
          .toList();
      final List<double> sortedLum = List.from(lumList)..sort();
      final double medianLum = sortedLum[sortedLum.length ~/ 2];

      // Calculate stripe contrast score for each column
      final List<double> rawScores = List.filled(colColors.length, 0.0);
      for (int i = 2; i < colColors.length - 2; i++) {
        final cur = colColors[i];
        final prev = colColors[i - 2];
        final next = colColors[i + 2];

        // Gradient / edge magnitude
        final double edge = ((cur[0] - prev[0]).abs() + (next[0] - cur[0]).abs() +
                             (cur[1] - prev[1]).abs() + (next[1] - cur[1]).abs() +
                             (cur[2] - prev[2]).abs() + (next[2] - cur[2]).abs()) / 3.0;

        // Color saturation (bands are often much more saturated than tan/grey bodies)
        final double maxC = math.max(cur[0], math.max(cur[1], cur[2]));
        final double minC = math.min(cur[0], math.min(cur[1], cur[2]));
        final double sat = maxC - minC;

        // Contrast from median body luminance
        final double curLum = 0.299 * cur[0] + 0.587 * cur[1] + 0.114 * cur[2];
        final double lumDiff = (curLum - medianLum).abs();

        rawScores[i] = edge * 1.5 + sat * 1.2 + lumDiff * 0.8;
      }

      // 3-point smoothing filter to remove sensor noise
      final List<double> scores = List.filled(rawScores.length, 0.0);
      for (int i = 1; i < rawScores.length - 1; i++) {
        scores[i] = (rawScores[i - 1] + rawScores[i] * 2.0 + rawScores[i + 1]) / 4.0;
      }

      // Physical minimum separation between bands on axial ceramic body (5.5% of guide width)
      final double minSeparation = gWidth * 0.055;
      final List<int> peaks = [];

      // Sort candidate columns by score descending
      final List<int> indices = List.generate(scores.length, (i) => i);
      indices.sort((a, b) => scores[b].compareTo(scores[a]));

      for (final idx in indices) {
        if (scores[idx] < 12.0) break; // noise floor
        final double norm = idx / gWidth;
        if (norm < 0.18 || norm > 0.82) continue; // skip outer wire leads
        bool tooClose = false;
        for (final p in peaks) {
          if ((p - idx).abs() < minSeparation) {
            tooClose = true;
            break;
          }
        }
        if (!tooClose) {
          peaks.add(idx);
          if (peaks.length >= bandCount + 3) break;
        }
      }

      List<int>? chosenPeaks;
      if (peaks.length >= bandCount) {
        peaks.sort();
        if (peaks.length > bandCount) {
          double bestAvgScore = -1.0;
          List<int> bestSubset = peaks.sublist(0, bandCount);
          for (int s = 0; s <= peaks.length - bandCount; s++) {
            final subset = peaks.sublist(s, s + bandCount);
            final double avgScore = subset.map((p) => scores[p]).reduce((a, b) => a + b) / bandCount;
            if (avgScore > bestAvgScore) {
              bestAvgScore = avgScore;
              bestSubset = subset;
            }
          }
          chosenPeaks = bestSubset;
        } else {
          chosenPeaks = peaks;
        }
      } else if (peaks.length == bandCount - 1 && peaks.isNotEmpty) {
        peaks.sort();
        final double avgGap = (peaks.last - peaks.first) / (peaks.length - 1);
        final int estLast = (peaks.last + avgGap * 1.1).round().clamp(0, gWidth - 1);
        peaks.add(estLast);
        peaks.sort();
        chosenPeaks = peaks;
      }

      if (chosenPeaks != null && chosenPeaks.length == bandCount) {
        final List<int> ordered = isReversed ? chosenPeaks.reversed.toList() : chosenPeaks;
        return ordered.map((p) => (p / gWidth).clamp(0.08, 0.92)).toList();
      }
    } catch (_) {}
    return null;
  }

  static bool detectIsReversed(
    Uint8List? imageBytes,
    int bandCount, {
    double? viewportWidth,
    double? viewportHeight,
  }) {
    if (imageBytes == null || imageBytes.isEmpty) return false;
    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null || decoded.width < 50 || decoded.height < 30) return false;

      final int w = decoded.width;
      final int h = decoded.height;

      int gLeft, gRight, gTop, gBottom;
      if (viewportWidth != null && viewportHeight != null && viewportWidth > 0 && viewportHeight > 0) {
        final double scale = math.max(viewportWidth / w, viewportHeight / h);
        final double renderedW = w * scale;
        final double renderedH = h * scale;
        final double cropX = (renderedW - viewportWidth) / 2.0;
        final double cropY = (renderedH - viewportHeight) / 2.0;
        final double guideViewLeft = viewportWidth * 0.20;
        final double guideViewRight = viewportWidth * 0.80;
        final double guideViewTop = viewportHeight * 0.35;
        final double guideViewBottom = viewportHeight * 0.65;
        gLeft = ((guideViewLeft + cropX) / scale).clamp(0.0, w - 1.0).round();
        gRight = ((guideViewRight + cropX) / scale).clamp(0.0, w - 1.0).round();
        gTop = ((guideViewTop + cropY) / scale).clamp(0.0, h - 1.0).round();
        gBottom = ((guideViewBottom + cropY) / scale).clamp(0.0, h - 1.0).round();
      } else {
        gLeft = (w * 0.20).round();
        gRight = (w * 0.80).round();
        gTop = (h * 0.35).round();
        gBottom = (h * 0.65).round();
      }

      final int gWidth = gRight - gLeft;
      final int gHeight = gBottom - gTop;
      if (gWidth < 40 || gHeight < 10) return false;

      final int yCenter = (gTop + gBottom) ~/ 2;
      double leftLum = 0, rightLum = 0;
      int leftCount = 0, rightCount = 0;
      for (int x = gLeft + (gWidth * 0.22).round(); x <= gLeft + (gWidth * 0.32).round(); x++) {
        for (int y = yCenter - 4; y <= yCenter + 4; y++) {
          final p = decoded.getPixel(x.clamp(0, w - 1), y.clamp(0, h - 1));
          leftLum += 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
          leftCount++;
        }
      }
      for (int x = gLeft + (gWidth * 0.50).round(); x <= gLeft + (gWidth * 0.62).round(); x++) {
        for (int y = yCenter - 4; y <= yCenter + 4; y++) {
          final p = decoded.getPixel(x.clamp(0, w - 1), y.clamp(0, h - 1));
          rightLum += 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
          rightCount++;
        }
      }
      final double avgLeftLum = leftCount > 0 ? leftLum / leftCount : 0.0;
      final double avgRightLum = rightCount > 0 ? rightLum / rightCount : 0.0;

      if (avgLeftLum > avgRightLum + 15.0) {
        return true;
      }
    } catch (_) {}
    return false;
  }
}

/// Interactive overlay widget positioned directly over the captured resistor image.
class InteractiveBandOverlay extends StatefulWidget {
  final int bandCount;
  final int band1Index;
  final int band2Index;
  final int band3Index;
  final int band4Index;
  final int band5Index;
  final int band6Index;
  final Function(int bandIndex, int colorIndex) onBandColorChanged;
  final double viewportWidth;
  final double viewportHeight;
  final List<double>? detectedAxisPositions;
  final Uint8List? capturedImageBytes;

  const InteractiveBandOverlay({
    super.key,
    required this.bandCount,
    required this.band1Index,
    required this.band2Index,
    required this.band3Index,
    required this.band4Index,
    required this.band5Index,
    required this.band6Index,
    required this.onBandColorChanged,
    required this.viewportWidth,
    required this.viewportHeight,
    this.detectedAxisPositions,
    this.capturedImageBytes,
  });

  @override
  State<InteractiveBandOverlay> createState() => _InteractiveBandOverlayState();
}

class _InteractiveBandOverlayState extends State<InteractiveBandOverlay> {
  late List<double> _bandNormalizedX;
  int? _activeBandIndex;
  bool _isAlignmentMode = false;

  @override
  void initState() {
    super.initState();
    _initPositions();
  }

  @override
  void didUpdateWidget(covariant InteractiveBandOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bandCount != widget.bandCount ||
        oldWidget.detectedAxisPositions != widget.detectedAxisPositions ||
        oldWidget.capturedImageBytes != widget.capturedImageBytes) {
      _initPositions();
    }
  }

  void _initPositions() {
    bool isReversed = false;

    // 1. Priority A: Check if detectedAxisPositions indicates right-to-left
    if (widget.detectedAxisPositions != null && widget.detectedAxisPositions!.length >= 2) {
      if (widget.detectedAxisPositions!.first > widget.detectedAxisPositions!.last) {
        isReversed = true;
      }
    } else {
      // 2. Priority B: Tolerance color rule (Gold/Silver is always the last band)
      final int tolIndex = widget.bandCount == 4
          ? widget.band4Index
          : (widget.bandCount == 5 ? widget.band5Index : widget.band6Index);
      final tolColor = ResistorScannerService.toleranceColors[
          tolIndex.clamp(0, ResistorScannerService.toleranceColors.length - 1)];
      if (tolColor.name == 'Gold' || tolColor.name == 'Silver') {
        if (widget.capturedImageBytes != null) {
          isReversed = OpticalStripeDetector.detectIsReversed(
            widget.capturedImageBytes,
            widget.bandCount,
            viewportWidth: widget.viewportWidth,
            viewportHeight: widget.viewportHeight,
          );
        }
      }
    }

    // 3. Priority C: Optical stripe detector on actual image bytes
    if (widget.capturedImageBytes != null) {
      final opticalStripes = OpticalStripeDetector.detectStripes(
        widget.capturedImageBytes,
        widget.bandCount,
        viewportWidth: widget.viewportWidth,
        viewportHeight: widget.viewportHeight,
        isReversed: isReversed,
      );
      if (opticalStripes != null && opticalStripes.length == widget.bandCount) {
        _bandNormalizedX = opticalStripes;
        return;
      }
    }

    // 4. Priority D: Detected physical candidate positions mapped to guide
    if (widget.detectedAxisPositions != null &&
        widget.detectedAxisPositions!.length == widget.bandCount) {
      _bandNormalizedX = widget.detectedAxisPositions!
          .map((x) => (0.24 + x * 0.36).clamp(0.12, 0.88))
          .toList();
      return;
    }

    // 5. Fallback: Calibrated physical axial resistor stripe anchors on central ceramic body
    if (isReversed) {
      if (widget.bandCount == 4) {
        _bandNormalizedX = [0.54, 0.45, 0.36, 0.26];
      } else if (widget.bandCount == 5) {
        _bandNormalizedX = [0.55, 0.47, 0.40, 0.33, 0.26];
      } else {
        _bandNormalizedX = [0.56, 0.49, 0.43, 0.37, 0.31, 0.25];
      }
    } else {
      if (widget.bandCount == 4) {
        _bandNormalizedX = [0.26, 0.36, 0.45, 0.54];
      } else if (widget.bandCount == 5) {
        _bandNormalizedX = [0.26, 0.33, 0.40, 0.47, 0.55];
      } else {
        _bandNormalizedX = [0.25, 0.31, 0.37, 0.43, 0.49, 0.56];
      }
    }
  }

  void _flipOrientation() {
    setState(() {
      _bandNormalizedX = _bandNormalizedX.reversed.toList();
    });
  }

  void _shiftAll(double delta) {
    setState(() {
      _bandNormalizedX = _bandNormalizedX
          .map((x) => (x + delta).clamp(0.06, 0.94))
          .toList();
    });
  }

  void _scaleSpacing(double factor) {
    setState(() {
      final double center =
          _bandNormalizedX.reduce((a, b) => a + b) / _bandNormalizedX.length;
      _bandNormalizedX = _bandNormalizedX.map((x) {
        return (center + (x - center) * factor).clamp(0.06, 0.94);
      }).toList();
    });
  }

  void _autoDetect() {
    final bool isReversed = _bandNormalizedX.first > _bandNormalizedX.last;
    final detected = OpticalStripeDetector.detectStripes(
      widget.capturedImageBytes,
      widget.bandCount,
      viewportWidth: widget.viewportWidth,
      viewportHeight: widget.viewportHeight,
      isReversed: isReversed,
    );
    if (detected != null && detected.length == widget.bandCount) {
      setState(() {
        _bandNormalizedX = List.from(detected);
      });
    } else {
      _resetPositions();
    }
  }

  void _resetPositions() {
    setState(() {
      final bool isReversed = _bandNormalizedX.first > _bandNormalizedX.last;
      if (isReversed) {
        if (widget.bandCount == 4) {
          _bandNormalizedX = [0.54, 0.45, 0.36, 0.26];
        } else if (widget.bandCount == 5) {
          _bandNormalizedX = [0.55, 0.47, 0.40, 0.33, 0.26];
        } else {
          _bandNormalizedX = [0.56, 0.49, 0.43, 0.37, 0.31, 0.25];
        }
      } else {
        if (widget.bandCount == 4) {
          _bandNormalizedX = [0.26, 0.36, 0.45, 0.54];
        } else if (widget.bandCount == 5) {
          _bandNormalizedX = [0.26, 0.33, 0.40, 0.47, 0.55];
        } else {
          _bandNormalizedX = [0.25, 0.31, 0.37, 0.43, 0.49, 0.56];
        }
      }
    });
  }

  ResistorBandInfo _getBandInfo(int index) {
    if (index == 0) return ResistorScannerService.digitColors[widget.band1Index.clamp(0, 9)];
    if (index == 1) return ResistorScannerService.digitColors[widget.band2Index.clamp(0, 9)];
    if (index == 2) {
      return widget.bandCount == 4
          ? ResistorScannerService.multiplierColors[widget.band3Index.clamp(0, ResistorScannerService.multiplierColors.length - 1)]
          : ResistorScannerService.digitColors[widget.band3Index.clamp(0, 9)];
    }
    if (index == 3) {
      return widget.bandCount == 4
          ? ResistorScannerService.toleranceColors[widget.band4Index.clamp(0, ResistorScannerService.toleranceColors.length - 1)]
          : ResistorScannerService.multiplierColors[widget.band4Index.clamp(0, ResistorScannerService.multiplierColors.length - 1)];
    }
    if (index == 4) {
      return ResistorScannerService.toleranceColors[widget.band5Index.clamp(0, ResistorScannerService.toleranceColors.length - 1)];
    }
    return ResistorScannerService.tempCoColors[widget.band6Index.clamp(0, ResistorScannerService.tempCoColors.length - 1)];
  }

  int _getCurrentValue(int index) {
    if (index == 0) return widget.band1Index;
    if (index == 1) return widget.band2Index;
    if (index == 2) return widget.band3Index;
    if (index == 3) return widget.band4Index;
    if (index == 4) return widget.band5Index;
    return widget.band6Index;
  }

  void _openColorPicker(int bandIndex) {
    setState(() => _activeBandIndex = bandIndex);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BandColorPickerModal(
        bandIndex: bandIndex,
        bandCount: widget.bandCount,
        currentValue: _getCurrentValue(bandIndex),
        onColorSelected: (newVal) {
          widget.onBandColorChanged(bandIndex, newVal);
        },
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _activeBandIndex = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double guideWidth = widget.viewportWidth * 0.60;
    final double guideHeight = widget.viewportHeight * 0.30;
    final double guideLeft = (widget.viewportWidth - guideWidth) / 2;
    final double guideTop = (widget.viewportHeight - guideHeight) / 2;
    final double resistorCenterY = guideTop + guideHeight / 2;

    final double bandRectHeight = guideHeight * 0.72;
    final double bandRectWidth =
        (guideWidth / (widget.bandCount + 2.5)).clamp(15.0, 24.0);
    const double boxWidth = 98.0;
    const double minGap = 6.0;
    final double minLeft = 6.0;
    final double maxLeft = widget.viewportWidth - boxWidth - 6.0;

    final List<_BandPlacement> rawPlacements = [];
    for (int i = 0; i < widget.bandCount; i++) {
      final double bandX = guideLeft + guideWidth * _bandNormalizedX[i];
      final bool isTop = i % 2 == 0;
      final info = _getBandInfo(i);

      final Rect bandRect = Rect.fromCenter(
        center: Offset(bandX, resistorCenterY),
        width: bandRectWidth,
        height: bandRectHeight,
      );

      rawPlacements.add(_BandPlacement(
        bandIndex: i,
        bandX: bandX,
        bandRect: bandRect,
        isTop: isTop,
        info: info,
        isActive: _activeBandIndex == i,
        boxLeft: (bandX - boxWidth / 2).clamp(minLeft, maxLeft),
      ));
    }

    void resolveTierCollisions(List<_BandPlacement> tier) {
      if (tier.length <= 1) return;
      tier.sort((a, b) => a.bandX.compareTo(b.bandX));

      final List<double> lefts = tier.map((p) => p.boxLeft).toList();

      for (int i = 1; i < lefts.length; i++) {
        if (lefts[i] < lefts[i - 1] + boxWidth + minGap) {
          lefts[i] = lefts[i - 1] + boxWidth + minGap;
        }
      }

      if (lefts.last > maxLeft) {
        lefts[lefts.length - 1] = maxLeft;
        for (int i = lefts.length - 2; i >= 0; i--) {
          if (lefts[i] > lefts[i + 1] - boxWidth - minGap) {
            lefts[i] = lefts[i + 1] - boxWidth - minGap;
          }
        }
      }

      if (lefts.first < minLeft) {
        lefts[0] = minLeft;
        for (int i = 1; i < lefts.length; i++) {
          if (lefts[i] < lefts[i - 1] + boxWidth + minGap) {
            lefts[i] = lefts[i - 1] + boxWidth + minGap;
          }
        }
      }

      for (int i = 0; i < tier.length; i++) {
        final p = tier[i];
        tier[i] = _BandPlacement(
          bandIndex: p.bandIndex,
          bandX: p.bandX,
          bandRect: p.bandRect,
          isTop: p.isTop,
          info: p.info,
          isActive: p.isActive,
          boxLeft: lefts[i].clamp(minLeft, maxLeft),
        );
      }
    }

    final topTier = rawPlacements.where((p) => p.isTop).toList();
    final bottomTier = rawPlacements.where((p) => !p.isTop).toList();
    resolveTierCollisions(topTier);
    resolveTierCollisions(bottomTier);

    final List<_BandPlacement> placements = [...topTier, ...bottomTier]
      ..sort((a, b) => a.bandIndex.compareTo(b.bandIndex));

    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer A: Technical Wireframes, Lines & Pointing Arrows CustomPainter
        Positioned.fill(
          child: CustomPaint(
            painter: _BandOverlayLinesPainter(
              placements: placements,
              viewportHeight: widget.viewportHeight,
            ),
          ),
        ),

        // Layer B: Top Controls Bar (Alignment Mode Toggle & Status Hint)
        Positioned(
          top: 8,
          right: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hint Tag
              IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    _isAlignmentMode ? 'SLIDE BANDS TO STRIPES' : 'TAP BOX TO EDIT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _isAlignmentMode
                          ? const Color(0xFF10B981)
                          : const Color(0xFF00E5FF),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Alignment Toggle Button
              GestureDetector(
                onTap: () => setState(() => _isAlignmentMode = !_isAlignmentMode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isAlignmentMode
                        ? const Color(0xFF10B981)
                        : const Color(0xFF0B132B).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isAlignmentMode
                          ? Colors.white
                          : const Color(0xFF00E5FF).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isAlignmentMode
                            ? const Color(0xFF10B981).withValues(alpha: 0.5)
                            : Colors.black.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isAlignmentMode
                            ? Icons.check_circle_rounded
                            : Icons.tune_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isAlignmentMode ? 'DONE' : 'ALIGN',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Layer C: Interactive Colored Boxes along top & bottom tiers
        for (final p in placements)
          _buildInteractiveBox(
            placement: p,
            guideWidth: guideWidth,
          ),

        // Layer D: Interactive Touch Targets over the highlighted rectangle wireframes
        for (final p in placements)
          _buildBandWireframeTouchTarget(p, guideWidth),

        // Layer E: Floating Fine-Tune Alignment Toolbar (Active only in Alignment Mode)
        if (_isAlignmentMode)
          Positioned(
            bottom: 50,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF060B18).withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
                    width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHudBtn(
                      icon: Icons.arrow_back_rounded,
                      label: 'Shift L',
                      onTap: () => _shiftAll(-0.02),
                    ),
                    const SizedBox(width: 4),
                    _buildHudBtn(
                      icon: Icons.arrow_forward_rounded,
                      label: 'Shift R',
                      onTap: () => _shiftAll(0.02),
                    ),
                    const SizedBox(width: 4),
                    _buildHudBtn(
                      icon: Icons.unfold_less_rounded,
                      label: 'Closer',
                      onTap: () => _scaleSpacing(0.92),
                    ),
                    const SizedBox(width: 4),
                    _buildHudBtn(
                      icon: Icons.unfold_more_rounded,
                      label: 'Wider',
                      onTap: () => _scaleSpacing(1.08),
                    ),
                    const SizedBox(width: 4),
                    _buildHudBtn(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Auto',
                      onTap: _autoDetect,
                    ),
                    const SizedBox(width: 4),
                    _buildHudBtn(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Flip',
                      onTap: _flipOrientation,
                    ),
                    const SizedBox(width: 4),
                    _buildHudBtn(
                      icon: Icons.refresh_rounded,
                      label: 'Reset',
                      onTap: _resetPositions,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHudBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF00E5FF), size: 12),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveBox({
    required _BandPlacement placement,
    required double guideWidth,
  }) {
    const double boxWidth = 98.0;
    const double boxHeight = 32.0;

    final double boxLeft = placement.boxLeft;
    final double boxTop =
        placement.isTop ? 14.0 : widget.viewportHeight - 14.0 - boxHeight;

    final bool isBlack = placement.info.color == const Color(0xFF212121) ||
        placement.info.color.computeLuminance() < 0.05;
    final Color borderColor =
        isBlack ? const Color(0xFF00E5FF) : placement.info.color;

    return Positioned(
      left: boxLeft,
      top: boxTop,
      width: boxWidth,
      height: boxHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_isAlignmentMode) {
            _openColorPicker(placement.bandIndex);
          }
        },
        onHorizontalDragUpdate: _isAlignmentMode
            ? (details) {
                setState(() {
                  final double deltaNorm = details.delta.dx / guideWidth;
                  _bandNormalizedX[placement.bandIndex] =
                      (_bandNormalizedX[placement.bandIndex] + deltaNorm)
                          .clamp(0.06, 0.94);
                });
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: const Color(0xFF070C18).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: placement.isActive
                  ? const Color(0xFF00E5FF)
                  : borderColor.withValues(alpha: 0.85),
              width: placement.isActive ? 2.0 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(
                    alpha: placement.isActive ? 0.55 : 0.30),
                blurRadius: placement.isActive ? 14 : 8,
                spreadRadius: placement.isActive ? 2 : 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Swatch Circle
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: placement.info.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: placement.info.color.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              // Band Name
              Expanded(
                child: Text(
                  'B${placement.bandIndex + 1} ${placement.info.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(
                _isAlignmentMode
                    ? Icons.drag_indicator_rounded
                    : Icons.arrow_drop_down_rounded,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBandWireframeTouchTarget(_BandPlacement placement, double guideWidth) {
    const double pad = 8.0;
    return Positioned(
      left: placement.bandRect.left - pad,
      top: placement.bandRect.top - pad,
      width: placement.bandRect.width + pad * 2,
      height: placement.bandRect.height + pad * 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!_isAlignmentMode) {
            _openColorPicker(placement.bandIndex);
          }
        },
        onHorizontalDragUpdate: _isAlignmentMode
            ? (details) {
                setState(() {
                  final double deltaNorm = details.delta.dx / guideWidth;
                  _bandNormalizedX[placement.bandIndex] =
                      (_bandNormalizedX[placement.bandIndex] + deltaNorm)
                          .clamp(0.06, 0.94);
                });
              }
            : null,
        child: Container(
          color: Colors.transparent, // Expanded touch target directly over the highlighted stripe
        ),
      ),
    );
  }
}

class _BandPlacement {
  final int bandIndex;
  final double bandX;
  final Rect bandRect;
  final bool isTop;
  final ResistorBandInfo info;
  final bool isActive;
  final double boxLeft;

  _BandPlacement({
    required this.bandIndex,
    required this.bandX,
    required this.bandRect,
    required this.isTop,
    required this.info,
    required this.isActive,
    required this.boxLeft,
  });
}

/// Custom painter for rectangle wireframes and pointer arrows pointing to the resistor bands.
class _BandOverlayLinesPainter extends CustomPainter {
  final List<_BandPlacement> placements;
  final double viewportHeight;

  _BandOverlayLinesPainter({
    required this.placements,
    required this.viewportHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double boxHeight = 32.0;
    const double boxWidth = 98.0;

    for (final p in placements) {
      final isBlack = p.info.color == const Color(0xFF212121) ||
          p.info.color.computeLuminance() < 0.05;
      final Color wireframeColor =
          isBlack ? const Color(0xFF00E5FF) : p.info.color;

      // -------------------------------------------------------------
      // 1. RECTANGLE WIREFRAME HIGHLIGHTING THE RESISTOR BAND
      // -------------------------------------------------------------
      final rrect = RRect.fromRectAndRadius(
        p.bandRect,
        const Radius.circular(3.0),
      );

      // 1a. Inner Translucent Highlight Wash
      final fillPaint = Paint()
        ..color = wireframeColor.withValues(alpha: p.isActive ? 0.32 : 0.16)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      // 1b. Outer Glow Aura Stroke
      final auraPaint = Paint()
        ..color = wireframeColor.withValues(alpha: p.isActive ? 0.65 : 0.30)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect, auraPaint);

      // 1c. Crisp Rectangle Wireframe Stroke
      final wireframePaint = Paint()
        ..color = wireframeColor
        ..strokeWidth = p.isActive ? 2.4 : 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect, wireframePaint);

      // 1d. Corner CAD Brackets (High-Tech Reticle Accents)
      final cornerPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.square
        ..style = PaintingStyle.stroke;
      const double cLen = 4.5;
      // Top-Left
      canvas.drawLine(Offset(p.bandRect.left, p.bandRect.top + cLen), Offset(p.bandRect.left, p.bandRect.top), cornerPaint);
      canvas.drawLine(Offset(p.bandRect.left, p.bandRect.top), Offset(p.bandRect.left + cLen, p.bandRect.top), cornerPaint);
      // Top-Right
      canvas.drawLine(Offset(p.bandRect.right - cLen, p.bandRect.top), Offset(p.bandRect.right, p.bandRect.top), cornerPaint);
      canvas.drawLine(Offset(p.bandRect.right, p.bandRect.top), Offset(p.bandRect.right, p.bandRect.top + cLen), cornerPaint);
      // Bottom-Left
      canvas.drawLine(Offset(p.bandRect.left, p.bandRect.bottom - cLen), Offset(p.bandRect.left, p.bandRect.bottom), cornerPaint);
      canvas.drawLine(Offset(p.bandRect.left, p.bandRect.bottom), Offset(p.bandRect.left + cLen, p.bandRect.bottom), cornerPaint);
      // Bottom-Right
      canvas.drawLine(Offset(p.bandRect.right - cLen, p.bandRect.bottom), Offset(p.bandRect.right, p.bandRect.bottom), cornerPaint);
      canvas.drawLine(Offset(p.bandRect.right, p.bandRect.bottom), Offset(p.bandRect.right, p.bandRect.bottom - cLen), cornerPaint);

      // -------------------------------------------------------------
      // 2. CONNECTING LINE AND DIRECTIONAL POINTER ARROW
      // -------------------------------------------------------------
      final double boxLeft = p.boxLeft;
      final double boxCenterX = boxLeft + boxWidth / 2;

      final double startY =
          p.isTop ? 14.0 + boxHeight : viewportHeight - 14.0 - boxHeight;
      final double arrowTipY = p.isTop ? p.bandRect.top : p.bandRect.bottom;
      final double arrowBaseY =
          p.isTop ? arrowTipY - 9.0 : arrowTipY + 9.0;

      // Outer glow line
      final lineAuraPaint = Paint()
        ..color = wireframeColor.withValues(alpha: p.isActive ? 0.45 : 0.22)
        ..strokeWidth = 3.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Inner crisp solid line
      final lineCorePaint = Paint()
        ..color = wireframeColor
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final linePath = Path();
      linePath.moveTo(boxCenterX, startY);

      if ((boxCenterX - p.bandX).abs() > 3.0) {
        final double midY = startY + (arrowBaseY - startY) * 0.45;
        linePath.lineTo(boxCenterX, midY);
        linePath.lineTo(p.bandX, midY + (p.isTop ? 7.0 : -7.0));
        linePath.lineTo(p.bandX, arrowBaseY);
      } else {
        linePath.lineTo(p.bandX, arrowBaseY);
      }

      canvas.drawPath(linePath, lineAuraPaint);
      canvas.drawPath(linePath, lineCorePaint);

      // -------------------------------------------------------------
      // 3. CRISP POINTER ARROW HEAD DIRECTING TO THE RECTANGLE WIREFRAME
      // -------------------------------------------------------------
      final arrowPath = Path();
      const double arrowW = 5.5;

      if (p.isTop) {
        // Points directly DOWN ▼ into the top edge of the band wireframe
        arrowPath.moveTo(p.bandX, arrowTipY);
        arrowPath.lineTo(p.bandX - arrowW, arrowBaseY);
        arrowPath.lineTo(p.bandX + arrowW, arrowBaseY);
        arrowPath.close();
      } else {
        // Points directly UP ▲ into the bottom edge of the band wireframe
        arrowPath.moveTo(p.bandX, arrowTipY);
        arrowPath.lineTo(p.bandX - arrowW, arrowBaseY);
        arrowPath.lineTo(p.bandX + arrowW, arrowBaseY);
        arrowPath.close();
      }

      final arrowFill = Paint()
        ..color = wireframeColor
        ..style = PaintingStyle.fill;

      final arrowBorder = Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      canvas.drawPath(arrowPath, arrowFill);
      canvas.drawPath(arrowPath, arrowBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _BandOverlayLinesPainter oldDelegate) => true;
}

/// Glassmorphic bottom sheet presenting most probable colors first, then other colors.
class BandColorPickerModal extends StatelessWidget {
  final int bandIndex;
  final int bandCount;
  final int currentValue;
  final ValueChanged<int> onColorSelected;

  const BandColorPickerModal({
    super.key,
    required this.bandIndex,
    required this.bandCount,
    required this.currentValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final result = BandProbabilityHelper.getOptionsForBand(
      bandIndex: bandIndex,
      bandCount: bandCount,
      currentValue: currentValue,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070C18).withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 30,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.35)),
                ),
                child: const Icon(Icons.palette_rounded, color: Color(0xFF00E5FF), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.bandTitle,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF8FAFC),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.roleDescription,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Options List
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SECTION 1: MOST PROBABLE COLORS
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFF00E5FF), size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'MOST PROBABLE COLORS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00E5FF),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ranked by optical scan match & standard E-series resistor coding:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Cards for Most Probable Colors
                  for (final option in result.mostProbable)
                    _buildProbableCard(context, option),

                  const SizedBox(height: 20),

                  // SECTION 2: ALL OTHER COLORS
                  Text(
                    'ALL OTHER OPTIONS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Grid for other color choices
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in result.otherOptions)
                        _buildOtherChip(context, option),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbableCard(BuildContext context, BandColorOption option) {
    final isBlack = option.color == const Color(0xFF212121) || option.color.computeLuminance() < 0.05;
    final Color borderGlow = isBlack ? const Color(0xFF00E5FF) : option.color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onColorSelected(option.index);
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: option.isCurrent
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.12)
                  : const Color(0xFF0F172A).withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: option.isCurrent
                    ? const Color(0xFF00E5FF)
                    : borderGlow.withValues(alpha: 0.45),
                width: option.isCurrent ? 1.8 : 1.2,
              ),
            ),
            child: Row(
              children: [
                // Glowing Circle Swatch
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: option.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: borderGlow.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Name and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            option.name,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF8FAFC),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option.valueLabel,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.reasonLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: option.isCurrent ? const Color(0xFF10B981) : const Color(0xFF67E8F9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Pill
                if (option.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'SELECTED',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherChip(BuildContext context, BandColorOption option) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onColorSelected(option.index);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 1.0),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                option.name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
