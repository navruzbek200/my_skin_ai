import 'package:real_beauty_ai/logic/skin_copy.dart';

import '../models/skin_analysis_result.dart';

export '../models/skin_result.dart';
export '../models/skin_analysis_result.dart';

class SkinLogic {
  static const _skinTypeByQ1 = {
    0: 'Quruq', 1: 'Quruq', 2: 'Aralash',
    3: 'Normal', 4: "Yog'li", 5: "Yog'li",
  };
  static const _skinTypeCode = {
    'Quruq': 'D', 'Aralash': 'C', 'Normal': 'N', "Yog'li": 'O',
  };
  static const int _threshold = 3;
  static const _oilySkinTypes = {"Yog'li"};

  // index -> recommendation code (scale >= threshold)
  static const _indexToRec = {
    1: 'P0', // pores
    4: 'Bh', // blackheads
    5: 'Wh', // whiteheads
    6: 'P',  // pigmentation
    7: 'Ew', // eye wrinkles
    8: 'Ed', // dark circles
    9: 'W',  // sagging
  };

  /// The finished sentences live in [SkinCopy], keyed by these same codes.
  /// This class decides *what* is true about somebody's skin; that one decides
  /// how to say it, and in which language.
  static SkinAnalysisResult analyze(List<dynamic> answers) {
    final q1 = _safeInt(answers, 0, defaultVal: 2);
    final skinType = _skinTypeByQ1[q1] ?? 'Normal';
    final skinCode = _skinTypeCode[skinType] ?? 'N';
    // The Uzbek text is baked into the stored result for backwards
    // compatibility — a profile saved by an older build has nothing but text —
    // but nothing reads it any more when the codes are present. See
    // `SkinCopy.baseRecommendationFor`.
    final baseRec = SkinCopy.baseRecommendations[skinCode]?.uz ?? '';

    final blocks = <Map<String, String>>[];
    void addCode(String code) {
      if (blocks.any((b) => b['code'] == code)) return;
      final rec = SkinCopy.blocks[code];
      if (rec != null) {
        blocks.add({
          'code': code,
          'title': rec.title.uz,
          'text': rec.text.uz,
        });
      }
    }

    // sensitive (index 2)
    if (_safeInt(answers, 2) >= _threshold) addCode('S');
    // acne (index 3) — oily → Ao, other → Ad
    if (_safeInt(answers, 3) >= _threshold) {
      addCode(_oilySkinTypes.contains(skinType) ? 'Ao' : 'Ad');
    }
    // threshold-driven blocks (index-mapped)
    for (final e in _indexToRec.entries) {
      if (_safeInt(answers, e.key) >= _threshold) addCode(e.value);
    }

    return SkinAnalysisResult(
      skinType: skinType,
      skinTypeCode: skinCode,
      baseRecommendation: baseRec,
      additionalBlocks: blocks,
    );
  }

  static int _safeInt(List<dynamic> answers, int index, {int defaultVal = 0}) {
    if (index < 0 || index >= answers.length) return defaultVal;
    final v = answers[index];
    return v is int ? v : defaultVal;
  }
}
