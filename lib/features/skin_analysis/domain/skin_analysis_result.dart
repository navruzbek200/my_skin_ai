enum SkinConcern {
  acne,
  darkSpots,
  pores,
  wrinkles,
  darkCircles,
  eyeBags,
  blackheads,
  oiliness,
  // TODO: redness — future phase, erythema index via CIELAB a* (sharp/jimp in Cloud Function)
}

/// Raw data returned by the Face++ cloud function.
/// Converted to [lib/models/SkinAnalysisResult] in the presentation layer.
class CloudSkinData {
  /// Per-concern severity scores 0–100 (higher = more severe). Null on API failure.
  final Map<SkinConcern, int>? concerns;
  final int? overallScore;

  /// English skin type from Face++: oily | dry | normal | combination
  final String detectedSkinType;
  final DateTime takenAt;

  const CloudSkinData({
    required this.concerns,
    required this.overallScore,
    required this.detectedSkinType,
    required this.takenAt,
  });
}

class SkinAnalysisException implements Exception {
  final String reason;
  const SkinAnalysisException(this.reason);

  @override
  String toString() => 'SkinAnalysisException($reason)';
}
