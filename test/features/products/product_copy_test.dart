import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/data/product_copy.g.dart';
import 'package:real_beauty_ai/data/product_vocabulary.dart';

/// The catalogue lives in Firestore and its documents have no translated
/// columns until somebody runs the seed upload. This table is what makes the
/// shelf read correctly before that happens — and offline, where Firestore is
/// not reachable at all.
void main() {
  test('covers the whole catalogue, not a sample of it', () {
    // 54 products: 37 distinct subtitles plus 206 benefit lines.
    expect(productCopy.length, greaterThanOrEqualTo(240));
  });

  test('translates a benefit line, which no vocabulary could', () {
    // Free prose. The term-by-term vocabulary underneath this table has no
    // chance with a sentence like this, which is the whole reason it exists.
    const uz = 'Kir, chang va ortiqcha yog\'ni samarali olib tashlaydi';
    final copy = productCopy[uz];
    expect(copy, isNotNull);
    expect(copy!.ru, 'Эффективно удаляет грязь, пыль и избыток себума');
    expect(copy.en, 'Removes dirt, dust and excess oil effectively');
  });

  test('translates a subtitle', () {
    final copy = productCopy['Guruchli tozalovchi penka'];
    expect(copy!.ru, 'Рисовая очищающая пенка');
    expect(copy.en, 'Rice cleansing foam');
  });

  test('every entry is keyed by its own Uzbek text', () {
    // The repository looks entries up by the Firestore value, so a key that
    // does not match its own `uz` field would never be found.
    for (final entry in productCopy.entries) {
      expect(entry.value.uz, entry.key);
    }
  });

  test('nothing is blank in any language', () {
    final blank = productCopy.entries
        .where((e) => e.value.ru.trim().isEmpty || e.value.en.trim().isEmpty)
        .map((e) => e.key)
        .toList();
    expect(blank, isEmpty, reason: blank.join('\n'));
  });

  test('the Russian is actually Russian', () {
    // Checking `ru != uz` is not enough: "50 ml" is legitimately "50 ml" in
    // English, and "SPF 50+ / PA++++" is the same everywhere. What cannot
    // legitimately happen is a Russian string with no Cyrillic in it when the
    // source contains real words — that is the copy-paste this guards against.
    final cyrillic = RegExp(r'[а-яА-ЯёЁ]');
    // Brand and standards vocabulary the packaging prints untranslated.
    const asPrinted = {
      'spf', 'aha', 'bha', 'pdrn', 'collagen', 'line', 'rose', 'gold',
      'cica', 'series', 'repair', 'wrinkle', 'cream', 'biome', 'deep',
      'cleansing', 'hypoallergenic', 'moisturizing', 'formula',
    };
    final translatable = RegExp('[A-Za-z]{4,}');

    final untranslated = <String>[];
    for (final entry in productCopy.entries) {
      final words = translatable
          .allMatches(entry.value.uz)
          .map((m) => m.group(0)!.toLowerCase())
          .where((w) => !asPrinted.contains(w))
          .toList();
      if (words.isEmpty) continue; // a volume or a standard — nothing to translate
      if (!cyrillic.hasMatch(entry.value.ru)) {
        untranslated.add('${entry.key}  ->  ${entry.value.ru}');
      }
    }
    expect(untranslated, isEmpty, reason: untranslated.join('\n'));
  });

  test('contains no stray characters from another script', () {
    // A CJK character slipped into a Russian string once; this is cheaper than
    // reading 243 entries again.
    final cjk = RegExp(r'[　-鿿]');
    final bad = <String>[];
    for (final entry in productCopy.entries) {
      if (cjk.hasMatch(entry.value.ru) || cjk.hasMatch(entry.value.en)) {
        bad.add(entry.key);
      }
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('the vocabulary still handles copy this table has never seen', () {
    // A product added to Firestore after this release falls through to the
    // term-by-term vocabulary rather than to nothing.
    expect(productCopy.containsKey('Hypoallergenic'), isFalse);
    expect(ProductVocabulary.translate('Hypoallergenic').ru,
        'Гипоаллергенное');
  });
}
