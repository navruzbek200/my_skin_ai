import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/data/product_vocabulary.dart';

/// Product subtitles come out of Firestore as one string with no translated
/// columns, so without this the claim under every product name stayed in
/// whatever language the catalogue happened to be typed in.
void main() {
  group('ProductVocabulary.translate', () {
    test('translates a single known claim', () {
      final t = ProductVocabulary.translate('Hypoallergenic');
      expect(t.ru, 'Гипоаллергенное');
      expect(t.en, 'Hypoallergenic');
      expect(t.uz, 'Gipoallergen');
    });

    test('keeps the separator and passes the volume through', () {
      // "150ml" is not a word to translate — it is a measurement, and the
      // bullet between the two halves has to survive.
      final t = ProductVocabulary.translate('Hypoallergenic • 150ml');
      expect(t.ru, 'Гипоаллергенное • 150ml');
      expect(t.en, 'Hypoallergenic • 150ml');
    });

    test('handles a slash-joined claim', () {
      final t = ProductVocabulary.translate('Cleansing / Moisturizing');
      expect(t.ru, 'Очищающее / Увлажняющее');
    });

    test('translates a catalogue line written in Uzbek', () {
      // The shelf is typed in mixed languages; both directions have to work.
      final t = ProductVocabulary.translate('Guruchli tozalovchi penka');
      expect(t.ru, 'Рисовая очищающая пенка');
      expect(t.en, 'Rice cleansing foam');
    });

    test('is case-insensitive', () {
      expect(ProductVocabulary.translate('MOISTURIZING').ru, 'Увлажняющее');
      expect(ProductVocabulary.translate('moisturizing').ru, 'Увлажняющее');
    });

    test('leaves an unknown claim readable rather than blank', () {
      // A new marketing line shows as typed — imperfect, but never empty.
      final t = ProductVocabulary.translate('Ceramide Barrier Complex');
      expect(t.uz, 'Ceramide Barrier Complex');
      expect(t.ru, 'Ceramide Barrier Complex');
      expect(t.en, 'Ceramide Barrier Complex');
    });

    test('leaves a rating untouched', () {
      // "SPF 50+ / PA++++" is a standard the packaging prints identically
      // everywhere; translating around it would be worse than leaving it.
      final t = ProductVocabulary.translate('SPF 50+ / PA++++');
      expect(t.ru, 'SPF 50+ / PA++++');
      expect(t.en, 'SPF 50+ / PA++++');
    });

    test('an empty subtitle stays empty in every language', () {
      final t = ProductVocabulary.translate('   ');
      expect(t.uz, '');
      expect(t.ru, '');
      expect(t.en, '');
    });

    test('mixes known and unknown segments without losing either', () {
      final t = ProductVocabulary.translate('Brightening • Vita C • 30ml');
      expect(t.ru, 'Осветляющее • Vita C • 30ml');
    });
  });
}
