import 'dart:math' as math;
import 'dart:ui';
import 'roboflow_constants.dart';
import 'scanner_models.dart';

class RoboflowPostProcessor {
  static ProcessedResult process(
    List<RoboflowDetection> rawDetections, {
    int? expectedBandCount,
  }) {
    if (rawDetections.isEmpty) {
      return const ProcessedResult(
        success: false,
        errorMessage: 'No detections returned from Roboflow.',
      );
    }

    // 1. Select the strongest resistor detection
    final resistorDetections = rawDetections
        .where((d) => d.className.toLowerCase() == 'resistor')
        .toList();

    if (resistorDetections.isEmpty) {
      return const ProcessedResult(
        success: false,
        errorMessage: 'No resistor detected in the image.',
      );
    }

    resistorDetections.sort((a, b) => b.confidence.compareTo(a.confidence));
    final bestResistor = resistorDetections.first;
    final resistorBox = bestResistor.bbox;

    // 2. Associate color detections with the resistor
    // Retain candidate bands if confidence >= floor (0.02) and within resistor area (with 25% margin)
    final marginX = resistorBox.width * 0.25;
    final marginY = resistorBox.height * 0.25;
    final expandedResistorBox = Rect.fromLTRB(
      resistorBox.left - marginX,
      resistorBox.top - marginY,
      resistorBox.right + marginX,
      resistorBox.bottom + marginY,
    );

    final rawBands = <_CandidateBand>[];
    for (final d in rawDetections) {
      final label = d.className.toLowerCase().trim();
      if (label == 'resistor') continue;

      final color = _parseColor(label);
      if (color == null || color == BandColor.none) continue;

      // Keep if above floor
      if (d.confidence < roboflowMinConfidenceFloor) continue;

      final center = Offset(
        d.bbox.left + d.bbox.width / 2.0,
        d.bbox.top + d.bbox.height / 2.0,
      );

      // Check if center or box intersects the expanded resistor box
      if (!expandedResistorBox.contains(center) &&
          !expandedResistorBox.overlaps(d.bbox)) {
        continue;
      }

      rawBands.add(_CandidateBand(
        color: color,
        confidence: d.confidence,
        bbox: d.bbox,
        center: center,
      ));
    }

    if (rawBands.isEmpty) {
      return const ProcessedResult(
        success: false,
        errorMessage: 'No resistor bands detected within the resistor area.',
      );
    }

    // 3. Remove duplicate detections
    // Sort by confidence descending so higher confidence detections are kept
    rawBands.sort((a, b) => b.confidence.compareTo(a.confidence));
    final dedupedBands = <_CandidateBand>[];
    final resistorDiag = math.sqrt(
      resistorBox.width * resistorBox.width + resistorBox.height * resistorBox.height,
    );

    for (final candidate in rawBands) {
      bool isDuplicate = false;
      for (final kept in dedupedBands) {
        final iou = _computeIoU(candidate.bbox, kept.bbox);
        final dist = (candidate.center - kept.center).distance;
        final isNear = dist < (resistorDiag * 0.08);

        // Duplicate if same color and overlapping/near, or if heavily overlapping (> 0.65)
        if ((candidate.color == kept.color && (iou > 0.35 || isNear)) ||
            (iou > 0.65)) {
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) {
        dedupedBands.add(candidate);
      }
    }

    if (dedupedBands.isEmpty) {
      return const ProcessedResult(
        success: false,
        errorMessage: 'No valid bands after duplicate removal.',
      );
    }

    // 4. Calculate resistor long axis & orientation
    final axisInfo = _calculateAxis(dedupedBands, resistorBox);
    final axisVector = axisInfo.axisVector;
    final orientationDirection = axisInfo.orientation;

    // 5. Project band centers onto axis
    final centerOrigin = Offset(
      resistorBox.left + resistorBox.width / 2.0,
      resistorBox.top + resistorBox.height / 2.0,
    );

    for (final band in dedupedBands) {
      final delta = band.center - centerOrigin;
      band.axisProjection = delta.dx * axisVector.dx + delta.dy * axisVector.dy;
    }

    // Sort bands along axis in ascending projection order
    dedupedBands.sort((a, b) => a.axisProjection.compareTo(b.axisProjection));

    // If more bands than 6, keep the best 4, 5, or 6
    var selectedBands = dedupedBands;
    if (selectedBands.length > 6) {
      selectedBands = _trimToBestBands(selectedBands, expectedBandCount ?? 5);
    }

    // 6. Evaluate both directions (forward vs reverse)
    final evaluatedOrder = _evaluateDirection(selectedBands);
    final orderedBands = evaluatedOrder.bands;

    // Normalize axis positions to 0.0 .. 1.0
    final minProj = orderedBands.first.axisProjection;
    final maxProj = orderedBands.last.axisProjection;
    final projRange = (maxProj - minProj).abs() > 1e-4 ? (maxProj - minProj) : 1.0;

    final resultBands = <DetectedBand>[];
    for (int i = 0; i < orderedBands.length; i++) {
      final b = orderedBands[i];
      final normPos = ((b.axisProjection - minProj) / projRange).clamp(0.0, 1.0);
      resultBands.add(DetectedBand(
        color: b.color,
        axisPosition: normPos,
        startPosition: (normPos - 0.05).clamp(0.0, 1.0),
        endPosition: (normPos + 0.05).clamp(0.0, 1.0),
        width: b.bbox.width,
        confidence: b.confidence,
      ));
    }

    // 7. Compute confidence heuristic
    // detectorConfidence = 0.25 * resistorConfidence + 0.30 * bandEvidence +
    //                      0.25 * geometricConsistency + 0.20 * bandCountAndCodeValidity
    final resistorConfidence = bestResistor.confidence.clamp(0.0, 1.0);
    final bandEvidence = resultBands.isNotEmpty
        ? (resultBands.map((b) => b.confidence).reduce((a, b) => a + b) / resultBands.length)
            .clamp(0.0, 1.0)
        : 0.0;

    final geometricConsistency = _computeGeometricConsistency(
      orderedBands,
      resistorBox,
      axisVector,
    );

    final bandCountAndCodeValidity = _computeCodeValidity(resultBands);

    final overallConfidence = (0.25 * resistorConfidence +
            0.30 * bandEvidence +
            0.25 * geometricConsistency +
            0.20 * bandCountAndCodeValidity)
        .clamp(0.0, 1.0);

    return ProcessedResult(
      success: true,
      bandCount: resultBands.length,
      bands: resultBands,
      overallConfidence: overallConfidence,
      orientationDirection: orientationDirection,
    );
  }

  // -----------------------------------------------------------------
  // Color mapping
  // -----------------------------------------------------------------
  static BandColor? _parseColor(String label) {
    switch (label) {
      case 'black':
        return BandColor.black;
      case 'brown':
        return BandColor.brown;
      case 'red':
        return BandColor.red;
      case 'orange':
        return BandColor.orange;
      case 'yellow':
        return BandColor.yellow;
      case 'green':
        return BandColor.green;
      case 'blue':
        return BandColor.blue;
      case 'violet':
      case 'purple':
        return BandColor.violet;
      case 'grey':
      case 'gray':
        return BandColor.grey;
      case 'white':
        return BandColor.white;
      case 'gold':
        return BandColor.gold;
      case 'silver':
        return BandColor.silver;
      default:
        return null;
    }
  }

  // -----------------------------------------------------------------
  // IoU calculation
  // -----------------------------------------------------------------
  static double _computeIoU(Rect a, Rect b) {
    final intersection = a.intersect(b);
    if (intersection.width <= 0 || intersection.height <= 0) return 0.0;
    final interArea = intersection.width * intersection.height;
    final unionArea = (a.width * a.height) + (b.width * b.height) - interArea;
    if (unionArea <= 0) return 0.0;
    return interArea / unionArea;
  }

  // -----------------------------------------------------------------
  // Long axis calculation (supports horizontal, vertical, diagonal)
  // -----------------------------------------------------------------
  static _AxisInfo _calculateAxis(List<_CandidateBand> bands, Rect resistorBox) {
    if (bands.length >= 2) {
      double sumX = 0.0;
      double sumY = 0.0;
      for (final b in bands) {
        sumX += b.center.dx;
        sumY += b.center.dy;
      }
      final meanX = sumX / bands.length;
      final meanY = sumY / bands.length;

      double cxx = 0.0;
      double cyy = 0.0;
      double cxy = 0.0;
      for (final b in bands) {
        final dx = b.center.dx - meanX;
        final dy = b.center.dy - meanY;
        cxx += dx * dx;
        cyy += dy * dy;
        cxy += dx * dy;
      }

      final delta = math.sqrt((cxx - cyy) * (cxx - cyy) + 4 * cxy * cxy);
      if (delta > 1e-4) {
        final lambda = (cxx + cyy + delta) / 2.0;
        double vx = cxy;
        double vy = lambda - cxx;
        if (vx.abs() < 1e-5 && vy.abs() < 1e-5) {
          vx = lambda - cyy;
          vy = cxy;
        }
        final len = math.sqrt(vx * vx + vy * vy);
        if (len > 1e-5) {
          vx /= len;
          vy /= len;
          // Ensure vector points rightwards or downwards
          if (vx < 0 || (vx.abs() < 1e-5 && vy < 0)) {
            vx = -vx;
            vy = -vy;
          }

          String orientation;
          if (vx.abs() > 0.85) {
            orientation = 'horizontal';
          } else if (vy.abs() > 0.85) {
            orientation = 'vertical';
          } else {
            orientation = 'diagonal';
          }

          return _AxisInfo(Offset(vx, vy), orientation);
        }
      }
    }

    // Fallback to resistor bbox aspect ratio
    if (resistorBox.width >= resistorBox.height) {
      return _AxisInfo(const Offset(1.0, 0.0), 'horizontal');
    } else {
      return _AxisInfo(const Offset(0.0, 1.0), 'vertical');
    }
  }

  // -----------------------------------------------------------------
  // Direction evaluation (Forward vs Reverse)
  // Constraint: Tolerance detection must NOT require last-band spacing to be an outlier.
  // Gold/Silver with normal spacing is fully accepted.
  // -----------------------------------------------------------------
  static _DirectionResult _evaluateDirection(List<_CandidateBand> bands) {
    if (bands.length < 2) {
      return _DirectionResult(bands, false);
    }

    final forwardScore = _scoreSequence(bands);
    final reversedBands = bands.reversed.toList();
    final reverseScore = _scoreSequence(reversedBands);

    if (reverseScore > forwardScore) {
      return _DirectionResult(reversedBands, true);
    }
    return _DirectionResult(bands, false);
  }

  static double _scoreSequence(List<_CandidateBand> seq) {
    double score = 0.0;
    final first = seq.first.color;
    final last = seq.last.color;

    // First band rules
    if (first == BandColor.gold || first == BandColor.silver) {
      score -= 50.0; // Gold/Silver cannot be first digit
    } else if (first == BandColor.black) {
      score -= 20.0; // Standard resistor never starts with Black
    } else if (_isValidDigitColor(first)) {
      score += 15.0;
    }

    // Last band (tolerance) rules
    if (last == BandColor.gold || last == BandColor.silver) {
      score += 25.0; // Gold/Silver is standard tolerance
    } else if (_isValidToleranceColor(last)) {
      score += 10.0; // Other tolerance colors (Brown, Red, Green, Blue, Violet, Grey)
    } else if (last == BandColor.black) {
      score -= 15.0; // Black is not a tolerance band
    }

    // Supporting geometric spacing evidence ONLY (optional bonus, not required)
    if (seq.length >= 4) {
      final spacings = <double>[];
      for (int i = 0; i < seq.length - 1; i++) {
        spacings.add((seq[i + 1].axisProjection - seq[i].axisProjection).abs());
      }
      if (spacings.length >= 2) {
        final lastGap = spacings.last;
        double sumOtherGaps = 0.0;
        for (int i = 0; i < spacings.length - 1; i++) {
          sumOtherGaps += spacings[i];
        }
        final meanOtherGap = sumOtherGaps / (spacings.length - 1);
        if (meanOtherGap > 1e-4 && lastGap > meanOtherGap * 1.25) {
          score += 2.0; // Small supporting geometric evidence
        }
      }
    }

    return score;
  }

  static bool _isValidDigitColor(BandColor c) {
    return c == BandColor.brown ||
        c == BandColor.red ||
        c == BandColor.orange ||
        c == BandColor.yellow ||
        c == BandColor.green ||
        c == BandColor.blue ||
        c == BandColor.violet ||
        c == BandColor.grey ||
        c == BandColor.white;
  }

  static bool _isValidToleranceColor(BandColor c) {
    return c == BandColor.gold ||
        c == BandColor.silver ||
        c == BandColor.brown ||
        c == BandColor.red ||
        c == BandColor.green ||
        c == BandColor.blue ||
        c == BandColor.violet ||
        c == BandColor.grey;
  }

  // -----------------------------------------------------------------
  // Geometric consistency (alignment along axis and spacing)
  // -----------------------------------------------------------------
  static double _computeGeometricConsistency(
    List<_CandidateBand> bands,
    Rect resistorBox,
    Offset axisVector,
  ) {
    if (bands.length < 2) return 0.5;

    final centerOrigin = Offset(
      resistorBox.left + resistorBox.width / 2.0,
      resistorBox.top + resistorBox.height / 2.0,
    );

    // Perpendicular vector
    final perpVector = Offset(-axisVector.dy, axisVector.dx);

    double totalPerpDist = 0.0;
    for (final b in bands) {
      final delta = b.center - centerOrigin;
      final perpDist = (delta.dx * perpVector.dx + delta.dy * perpVector.dy).abs();
      totalPerpDist += perpDist;
    }
    final meanPerpDist = totalPerpDist / bands.length;
    final shortDim = math.min(resistorBox.width, resistorBox.height);
    final normalizedPerpErr = shortDim > 0 ? (meanPerpDist / shortDim) : 0.0;

    // Linear alignment factor
    final alignmentFactor = (1.0 - (normalizedPerpErr * 2.0)).clamp(0.0, 1.0);

    // Spacing regularity factor
    double spacingFactor = 1.0;
    for (int i = 0; i < bands.length - 1; i++) {
      final gap = (bands[i + 1].axisProjection - bands[i].axisProjection).abs();
      if (gap < 1.0) {
        spacingFactor *= 0.8;
      }
    }

    return (0.7 * alignmentFactor + 0.3 * spacingFactor).clamp(0.0, 1.0);
  }

  // -----------------------------------------------------------------
  // Code validity heuristic (0.0 to 1.0)
  // -----------------------------------------------------------------
  static double _computeCodeValidity(List<DetectedBand> bands) {
    final count = bands.length;
    if (count < 3 || count > 6) return 0.2;

    final first = bands.first.color;
    final last = bands.last.color;

    bool validFirst = _isValidDigitColor(first);
    bool validLast = _isValidToleranceColor(last);

    if (count == 4) {
      // 4-band: digit, digit, multiplier, tolerance
      if (validFirst && validLast) {
        return (last == BandColor.gold || last == BandColor.silver) ? 1.0 : 0.9;
      } else if (validFirst || validLast) {
        return 0.6;
      }
      return 0.3;
    } else if (count == 5) {
      // 5-band: digit, digit, digit, multiplier, tolerance
      if (validFirst && validLast) {
        return (last == BandColor.gold || last == BandColor.silver) ? 1.0 : 0.9;
      } else if (validFirst || validLast) {
        return 0.6;
      }
      return 0.3;
    } else if (count == 6) {
      // 6-band: digit, digit, digit, multiplier, tolerance, tempCo
      // The 5th band is tolerance, 6th is tempCo
      final tolBand = bands[4].color;
      final tempCoBand = bands[5].color;
      bool validTol = _isValidToleranceColor(tolBand);
      bool validTempCo = tempCoBand == BandColor.brown ||
          tempCoBand == BandColor.red ||
          tempCoBand == BandColor.orange ||
          tempCoBand == BandColor.yellow ||
          tempCoBand == BandColor.blue ||
          tempCoBand == BandColor.violet;

      if (validFirst && validTol && validTempCo) {
        return 1.0;
      } else if (validFirst && validTol) {
        return 0.8;
      }
      return 0.4;
    }

    return 0.5;
  }

  // -----------------------------------------------------------------
  // Helper: trim to best N bands if too many detections
  // -----------------------------------------------------------------
  static List<_CandidateBand> _trimToBestBands(
    List<_CandidateBand> bands,
    int targetCount,
  ) {
    if (bands.length <= targetCount) return bands;
    final sortedByConf = List<_CandidateBand>.from(bands)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final trimmed = sortedByConf.take(targetCount).toList()
      ..sort((a, b) => a.axisProjection.compareTo(b.axisProjection));
    return trimmed;
  }
}

class _CandidateBand {
  final BandColor color;
  final double confidence;
  final Rect bbox;
  final Offset center;
  double axisProjection = 0.0;

  _CandidateBand({
    required this.color,
    required this.confidence,
    required this.bbox,
    required this.center,
  });
}

class _AxisInfo {
  final Offset axisVector;
  final String orientation;
  const _AxisInfo(this.axisVector, this.orientation);
}

class _DirectionResult {
  final List<_CandidateBand> bands;
  final bool reversed;
  const _DirectionResult(this.bands, this.reversed);
}
