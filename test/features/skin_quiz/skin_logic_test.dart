import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/logic/skin_logic.dart';

void main() {
  // Helper: builds a 12-element answer list with specific index overrides.
  List<dynamic> answers({Map<int, int> set = const {}}) {
    final list = List<dynamic>.filled(12, 0);
    set.forEach((k, v) => list[k] = v);
    return list;
  }

  // ── Skin type mapping ────────────────────────────────────────────────

  group('q1 → skinType', () {
    for (final entry in {
      0: ('Quruq', 'D'),
      1: ('Quruq', 'D'),
      2: ('Aralash', 'C'),
      3: ('Normal', 'N'),
      4: ("Yog'li", 'O'),
      5: ("Yog'li", 'O'),
    }.entries) {
      test('q1=${entry.key} → ${entry.value.$1}/${entry.value.$2}', () {
        final r = SkinLogic.analyze(answers(set: {0: entry.key}));
        expect(r.skinType, entry.value.$1);
        expect(r.skinTypeCode, entry.value.$2);
      });
    }
  });

  // ── Threshold concern blocks ─────────────────────────────────────────

  group('threshold blocks', () {
    test('all-zero answers (no primary concern) → no additional blocks', () {
      // idx-11=2 (dryness, null code) prevents primary concern injection.
      expect(SkinLogic.analyze(answers(set: {11: 2})).additionalBlocks, isEmpty);
    });

    test('sensitivity idx-2 = 3 → S block', () {
      final r = SkinLogic.analyze(answers(set: {2: 3}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'S'), isTrue);
    });

    test('sensitivity idx-2 = 2 → no S block', () {
      final r = SkinLogic.analyze(answers(set: {2: 2}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'S'), isFalse);
    });

    test('acne idx-3 = 4 + oily skin → Ao (not Ad)', () {
      final r = SkinLogic.analyze(answers(set: {0: 4, 3: 4}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'Ao'), isTrue);
      expect(r.additionalBlocks.any((b) => b['code'] == 'Ad'), isFalse);
    });

    test('acne idx-3 = 4 + dry skin → Ad (not Ao)', () {
      final r = SkinLogic.analyze(answers(set: {0: 0, 3: 4}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'Ad'), isTrue);
      expect(r.additionalBlocks.any((b) => b['code'] == 'Ao'), isFalse);
    });

    test('pores idx-1 = 5 → P0 block', () {
      final r = SkinLogic.analyze(answers(set: {1: 5}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'P0'), isTrue);
    });

    test('blackheads idx-4 = 3 → Bh block', () {
      final r = SkinLogic.analyze(answers(set: {4: 3}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'Bh'), isTrue);
    });

    test('whiteheads idx-5 = 3 → Wh block', () {
      final r = SkinLogic.analyze(answers(set: {5: 3}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'Wh'), isTrue);
    });

    test('pigmentation idx-6 = 4 → P block', () {
      final r = SkinLogic.analyze(answers(set: {6: 4}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'P'), isTrue);
    });

    test('eye wrinkles idx-7 = 3 → Ew block', () {
      final r = SkinLogic.analyze(answers(set: {7: 3}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'Ew'), isTrue);
    });

    test('dark circles idx-8 = 3 → Ed block', () {
      final r = SkinLogic.analyze(answers(set: {8: 3}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'Ed'), isTrue);
    });

    test('sagging idx-9 = 4 → W block', () {
      final r = SkinLogic.analyze(answers(set: {9: 4}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'W'), isTrue);
    });

    test('below-threshold (idx-4 = 2) → no Bh block', () {
      // idx-11=2 (dryness, null code) isolates threshold check from primary inject.
      final r = SkinLogic.analyze(answers(set: {4: 2, 11: 2}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'Bh'), isFalse);
    });
  });

  // ── Edge cases ───────────────────────────────────────────────────────

  group('edge cases', () {
    test('empty list → Aralash (q1 defaultVal=2), no blocks', () {
      // _safeInt([], 0, defaultVal:2) = 2 → _skinTypeByQ1[2] = 'Aralash'
      final r = SkinLogic.analyze([]);
      expect(r.skinType, 'Aralash');
      expect(r.additionalBlocks, isEmpty);
    });

    test('single-element list (only q1) → correct skin type, no blocks', () {
      final r = SkinLogic.analyze([4]);
      expect(r.skinType, "Yog'li");
      expect(r.additionalBlocks, isEmpty);
    });

    test('non-int q1 → treated as defaultVal=2 → Aralash', () {
      final r = SkinLogic.analyze(['oily', 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
      expect(r.skinType, 'Aralash');
    });

    test('out-of-range index reads → default 0, no extra blocks', () {
      // 3 answers — indices 3..11 out of range → all default 0 → no concern blocks
      final r = SkinLogic.analyze([3, 0, 0]);
      expect(r.skinType, 'Normal');
      expect(r.additionalBlocks, isEmpty);
    });
  });

  // ── Primary concern reordering ───────────────────────────────────────

  group('primary concern reordering', () {
    test('primary=1 (pigmentation) + P already triggered → P moves to front', () {
      final list = answers(set: {6: 4, 11: 1}); // pigmentation triggered + primary=P
      final r = SkinLogic.analyze(list);
      expect(r.additionalBlocks.first['code'], 'P');
    });

    test('primary=0 (blackhead) not triggered → Bh added at front', () {
      final r = SkinLogic.analyze(answers(set: {11: 0}));
      expect(r.additionalBlocks.isNotEmpty, isTrue);
      expect(r.additionalBlocks.first['code'], 'Bh');
    });

    test('primary=2 (dryness, null code) → blocks unchanged', () {
      final r = SkinLogic.analyze(answers(set: {11: 2}));
      expect(r.additionalBlocks, isEmpty);
    });

    test('primary=5 (sensitivity) + S triggered → S at front', () {
      final r = SkinLogic.analyze(answers(set: {2: 4, 4: 4, 11: 5}));
      // Bh and S both triggered; primary=S → S at front
      expect(r.additionalBlocks.first['code'], 'S');
    });
  });

  // ── Age note ─────────────────────────────────────────────────────────

  group('age note', () {
    test('age=3 (35–44) + no aging blocks → AgeNote appended', () {
      final r = SkinLogic.analyze(answers(set: {10: 3}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'AgeNote'), isTrue);
    });

    test('age=4 (45+) + no aging blocks → AgeNote appended', () {
      final r = SkinLogic.analyze(answers(set: {10: 4}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'AgeNote'), isTrue);
    });

    test('age=2 (25–34) → no AgeNote', () {
      final r = SkinLogic.analyze(answers(set: {10: 2}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'AgeNote'), isFalse);
    });

    test('age=3 + W block present → no AgeNote (already covered)', () {
      final r = SkinLogic.analyze(answers(set: {9: 5, 10: 3}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'W'), isTrue);
      expect(r.additionalBlocks.any((b) => b['code'] == 'AgeNote'), isFalse);
    });

    test('age=3 + Ew block present → no AgeNote', () {
      final r = SkinLogic.analyze(answers(set: {7: 4, 10: 3}));
      expect(r.additionalBlocks.any((b) => b['code'] == 'Ew'), isTrue);
      expect(r.additionalBlocks.any((b) => b['code'] == 'AgeNote'), isFalse);
    });
  });
}
