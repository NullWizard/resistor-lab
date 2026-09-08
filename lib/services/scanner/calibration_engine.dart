import 'scanner_models.dart';
import 'ensemble_engine.dart';

class DetectorStats {
  int totalTested = 0;
  int resistorDetectionCorrect = 0;
  int bandCountCorrect = 0;
  int orientationCorrect = 0;
  int individualColorsCorrect = 0;
  int individualColorsTotal = 0;
  int completeSequenceCorrect = 0;

  double get resistorAccuracy => totalTested == 0 ? 0 : resistorDetectionCorrect / totalTested;
  double get countAccuracy => totalTested == 0 ? 0 : bandCountCorrect / totalTested;
  double get orientationAccuracy => totalTested == 0 ? 0 : orientationCorrect / totalTested;
  double get colorAccuracy => individualColorsTotal == 0 ? 0 : individualColorsCorrect / individualColorsTotal;
  double get sequenceAccuracy => totalTested == 0 ? 0 : completeSequenceCorrect / totalTested;

  double getReliabilityScore() {
    return 0.50 * colorAccuracy +
           0.20 * sequenceAccuracy +
           0.15 * countAccuracy +
           0.10 * orientationAccuracy +
           0.05 * resistorAccuracy;
  }
}

class CalibrationEngine {
  final Map<String, DetectorStats> stats = {
    'VISION': DetectorStats(),
    'GEMINI': DetectorStats(),
    'PAPER_CV': DetectorStats(),
    'CENTERLINE': DetectorStats(),
  };

  void evaluate(String source, RecognitionCandidate candidate, ValidationRecord expected) {
    final s = stats[source]!;
    s.totalTested++;

    if (candidate.success && candidate.isResistor) {
      s.resistorDetectionCorrect++;
      if (candidate.bandCount == expected.expectedBandCount) {
        s.bandCountCorrect++;
        
        bool seqCorrect = true;
        for (int i = 0; i < expected.expectedColors.length; i++) {
           s.individualColorsTotal++;
           if (i < candidate.bands.length && candidate.bands[i].color == expected.expectedColors[i]) {
              s.individualColorsCorrect++;
           } else {
              seqCorrect = false;
           }
        }
        if (seqCorrect) {
           s.completeSequenceCorrect++;
           s.orientationCorrect++; // Simplified orientation check for sequence match
        }
      }
    }
  }

  EnsembleConfig deriveConfig() {
    double gScore = stats['GEMINI']?.getReliabilityScore() ?? 0.33;
    double pScore = stats['PAPER_CV']?.getReliabilityScore() ?? 0.33;
    double cScore = stats['CENTERLINE']?.getReliabilityScore() ?? 0.33;
    
    double total = gScore + pScore + cScore;
    if (total == 0) return const EnsembleConfig();
    
    return EnsembleConfig(
      geminiWeight: gScore / total,
      paperCvWeight: pScore / total,
      centerlineWeight: cScore / total,
    );
  }
}
