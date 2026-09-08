import 'scanner_models.dart';

class EnsembleConfig {
  final double geminiWeight;
  final double paperCvWeight;
  final double centerlineWeight;

  const EnsembleConfig({
    this.geminiWeight = 0.33,
    this.paperCvWeight = 0.33,
    this.centerlineWeight = 0.34,
  });
}

class EnsembleEngine {
  static RecognitionCandidate computeConsensus(List<RecognitionCandidate> candidates, {EnsembleConfig config = const EnsembleConfig()}) {
    if (candidates.isEmpty) {
      return const RecognitionCandidate(success: false, source: "ENSEMBLE", errorMessage: "No candidates provided.");
    }

    final validCands = candidates.where((c) => c.success && c.isResistor && c.bands.isNotEmpty).toList();
    
    if (validCands.isEmpty) {
      return const RecognitionCandidate(success: false, source: "ENSEMBLE", errorMessage: "No reliable detection of a resistor.");
    }

    double getWeight(String source) {
      if (source == "GEMINI" || source == "VISION") return config.geminiWeight;
      if (source == "PAPER_CV") return config.paperCvWeight;
      if (source == "CENTERLINE") return config.centerlineWeight;
      return 0.33;
    }

    // 1. Vote on Band Count
    Map<int, double> countVotes = {};
    for (var c in validCands) {
      countVotes[c.bandCount] = (countVotes[c.bandCount] ?? 0.0) + (getWeight(c.source) * c.overallConfidence);
    }
    int consensusCount = -1;
    double maxCountScore = -1.0;
    countVotes.forEach((count, score) {
      if (score > maxCountScore) {
        maxCountScore = score;
        consensusCount = count;
      }
    });

    if (consensusCount < 4 || consensusCount > 6) {
      return const RecognitionCandidate(success: false, source: "ENSEMBLE", errorMessage: "Could not establish valid band count.");
    }

    // Filter to candidates that have the consensus band count
    // Wait, what if we align them spatially instead of discarding?
    // "Before voting on colors, align detections from different engines... This is especially important when one detector detects a band slightly left or right of another."
    
    // Create clusters of bands based on their spatial axisPosition
    List<List<DetectedBand>> clusters = [];
    
    for (var cand in validCands) {
      for (var band in cand.bands) {
        bool added = false;
        for (var cluster in clusters) {
           double avgPos = cluster.map((b) => b.axisPosition).reduce((a, b) => a + b) / cluster.length;
           if ((band.axisPosition - avgPos).abs() < 0.1) {
             cluster.add(band);
             added = true;
             break;
           }
        }
        if (!added) {
          clusters.add([band]);
        }
      }
    }

    clusters.sort((a, b) {
      double avgA = a.map((x) => x.axisPosition).reduce((s, e) => s + e) / a.length;
      double avgB = b.map((x) => x.axisPosition).reduce((s, e) => s + e) / b.length;
      return avgA.compareTo(avgB);
    });

    // Take top N clusters where N = consensusCount based on the most total weight
    clusters.sort((a, b) => b.length.compareTo(a.length));
    if (clusters.length > consensusCount) {
       clusters = clusters.sublist(0, consensusCount);
    }
    clusters.sort((a, b) {
      double avgA = a.map((x) => x.axisPosition).reduce((s, e) => s + e) / a.length;
      double avgB = b.map((x) => x.axisPosition).reduce((s, e) => s + e) / b.length;
      return avgA.compareTo(avgB);
    });

    List<DetectedBand> finalBands = [];
    double totalBandConfidence = 0.0;

    for (var cluster in clusters) {
      Map<BandColor, double> colorVotes = {};
      double totalVotes = 0.0;
      
      double avgPos = 0;
      double avgWidth = 0;
      
      for (var band in cluster) {
        // Need to know source. But DetectedBand doesn't store source.
        // I will add source passing by looking up the candidate it came from.
        // Actually, just using the band's confidence as weight for now.
        double w = band.confidence; // Can refine if we pass source into DetectedBand
        colorVotes[band.color] = (colorVotes[band.color] ?? 0.0) + w;
        totalVotes += w;
        avgPos += band.axisPosition;
        avgWidth += band.width;
      }
      
      BandColor consensusColor = BandColor.none;
      double maxColorScore = -1.0;
      colorVotes.forEach((color, score) {
        if (score > maxColorScore) {
          maxColorScore = score;
          consensusColor = color;
        }
      });

      double bandConf = totalVotes > 0 ? (maxColorScore / totalVotes) : 0.0;
      
      finalBands.add(DetectedBand(
        color: consensusColor,
        axisPosition: avgPos / cluster.length,
        startPosition: (avgPos / cluster.length) - (avgWidth / cluster.length / 2),
        endPosition: (avgPos / cluster.length) + (avgWidth / cluster.length / 2),
        width: avgWidth / cluster.length,
        confidence: bandConf,
        agreementCount: cluster.length,
        totalDetectors: validCands.length,
        needsConfirmation: bandConf < 0.6 || cluster.length < validCands.length,
      ));
      totalBandConfidence += bandConf;
    }

    if (finalBands.length < 4 || finalBands.length > 6) {
      return RecognitionCandidate(success: false, source: "ENSEMBLE", errorMessage: "Spatial clustering yielded ${finalBands.length} bands, expected $consensusCount.");
    }

    // Determine Orientation
    bool shouldReverse = false;
    if (finalBands.isNotEmpty) {
       final first = finalBands.first.color;
       final last = finalBands.last.color;
       bool firstGS = first == BandColor.gold || first == BandColor.silver;
       bool lastGS = last == BandColor.gold || last == BandColor.silver;
       
       if (firstGS && !lastGS) {
          shouldReverse = true;
       } else if (lastGS && !firstGS) {
          shouldReverse = false;
       } else {
          double gapFirst = finalBands[1].axisPosition - finalBands[0].axisPosition;
          double gapLast = finalBands.last.axisPosition - finalBands[finalBands.length - 2].axisPosition;
          if (gapFirst > gapLast * 1.4) {
             shouldReverse = true;
          }
       }
    }

    if (shouldReverse) {
       finalBands = finalBands.reversed.toList();
    }

    return RecognitionCandidate(
       success: true,
       isResistor: true,
       bandCount: finalBands.length,
       bands: finalBands,
       overallConfidence: totalBandConfidence / finalBands.length,
       source: "ENSEMBLE",
    );
  }
}
