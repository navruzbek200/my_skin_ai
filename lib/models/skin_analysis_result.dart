import 'dart:convert';
import 'skin_result.dart';

enum AnalysisSource { quizEstimate, cameraAnalysis }

class SkinAnalysisResult {
  final String skinType;
  final String skinTypeCode;
  final String baseRecommendation;
  final List<Map<String, String>> additionalBlocks;
  final AnalysisSource source;

  /// Per-metric camera scores (0–1). Null when source == quizEstimate.
  final Map<String, double>? scores;

  /// When this analysis was produced. Defaults to now on construction.
  final DateTime takenAt;

  SkinAnalysisResult({
    required this.skinType,
    required this.skinTypeCode,
    required this.baseRecommendation,
    required this.additionalBlocks,
    this.source = AnalysisSource.quizEstimate,
    this.scores,
    DateTime? takenAt,
  }) : takenAt = takenAt ?? DateTime.now();

  /// Concern codes for RoutineEngine.generate(concerns: ...).
  Set<String> get concernCodes => additionalBlocks
      .map((b) => b['code'] ?? '')
      .where((c) => c.isNotEmpty)
      .toSet();

  /// Persist-safe form. LocalStore and RoutineEngine read this.
  SkinResult toSkinResult() => SkinResult(
        skinType: skinType,
        skinTypeCode: skinTypeCode,
        baseRecommendation: baseRecommendation,
        additionalBlocks: additionalBlocks,
      );

  Map<String, dynamic> toJson() => {
        'skinType': skinType,
        'skinTypeCode': skinTypeCode,
        'baseRecommendation': baseRecommendation,
        'additionalBlocks': additionalBlocks,
        'source': source.name,
        if (scores != null) 'scores': scores,
        'takenAt': takenAt.toIso8601String(),
      };

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> j) {
    final rawScores = j['scores'] as Map<String, dynamic>?;
    final rawBlocks = j['additionalBlocks'] as List<dynamic>?;
    return SkinAnalysisResult(
      skinType: j['skinType'] as String? ?? '',
      skinTypeCode: j['skinTypeCode'] as String? ?? '',
      baseRecommendation: j['baseRecommendation'] as String? ?? '',
      additionalBlocks: rawBlocks
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      source: AnalysisSource.values.firstWhere(
        (e) => e.name == (j['source'] as String?),
        orElse: () => AnalysisSource.quizEstimate,
      ),
      scores: rawScores?.map((k, v) => MapEntry(k, (v as num).toDouble())),
      takenAt: j['takenAt'] != null
          ? DateTime.tryParse(j['takenAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static SkinAnalysisResult? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      return SkinAnalysisResult.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
