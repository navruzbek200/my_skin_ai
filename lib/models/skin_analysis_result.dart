import 'dart:convert';
import 'skin_result.dart';

class SkinAnalysisResult {
  final String skinType;
  final String skinTypeCode;
  final String baseRecommendation;
  final List<Map<String, String>> additionalBlocks;
  final DateTime takenAt;

  SkinAnalysisResult({
    required this.skinType,
    required this.skinTypeCode,
    required this.baseRecommendation,
    required this.additionalBlocks,
    DateTime? takenAt,
  }) : takenAt = takenAt ?? DateTime.now();

  Set<String> get concernCodes => additionalBlocks
      .map((b) => b['code'] ?? '')
      .where((c) => c.isNotEmpty)
      .toSet();

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
        'takenAt': takenAt.toIso8601String(),
      };

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> j) {
    final rawBlocks = j['additionalBlocks'] as List<dynamic>?;
    return SkinAnalysisResult(
      skinType: j['skinType'] as String? ?? '',
      skinTypeCode: j['skinTypeCode'] as String? ?? '',
      baseRecommendation: j['baseRecommendation'] as String? ?? '',
      additionalBlocks: rawBlocks
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
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
