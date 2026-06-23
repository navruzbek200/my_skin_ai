import 'dart:convert';

// Canonical skin result produced by SkinLogic.analyze() and persisted to disk.
class SkinResult {
  final String skinType;
  final String skinTypeCode;
  final String baseRecommendation;
  final List<Map<String, String>> additionalBlocks;

  const SkinResult({
    required this.skinType,
    required this.skinTypeCode,
    required this.baseRecommendation,
    required this.additionalBlocks,
  });

  Map<String, dynamic> toJson() => {
        'skinType': skinType,
        'skinTypeCode': skinTypeCode,
        'baseRecommendation': baseRecommendation,
        'additionalBlocks': additionalBlocks,
      };

  factory SkinResult.fromJson(Map<String, dynamic> j) => SkinResult(
        skinType: j['skinType'] as String,
        skinTypeCode: (j['skinTypeCode'] as String?) ?? 'N',
        baseRecommendation: (j['baseRecommendation'] as String?) ?? '',
        additionalBlocks: (j['additionalBlocks'] as List<dynamic>?)
                ?.map((e) => Map<String, String>.from(e as Map))
                .toList() ??
            [],
      );

  String toJsonString() => jsonEncode(toJson());

  static SkinResult? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      return SkinResult.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
