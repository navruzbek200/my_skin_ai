import 'package:real_beauty_ai/core/l10n/localized_text.dart';

/// The claim printed under a product name, translated segment by segment.
///
/// Product subtitles come out of Firestore as one Uzbek-or-English string —
/// `"Hypoallergenic • 150ml"`, `"Guruchli tozalovchi penka"`, `"SPF 50+ /
/// PA++++"` — with no translated columns, so without this the line stayed in
/// whatever language the catalogue happened to be typed in.
///
/// They are not free prose: they are short claims drawn from a small marketing
/// vocabulary, joined by `•` or `/`, often with a volume on the end. So the
/// string is split on its separators, each piece is looked up, and the
/// separators are put back. A piece that is not in the table — a volume, an SPF
/// rating, a new claim — passes through untouched, which is right for
/// `150ml` and merely imperfect for the rest.
///
/// The repository still prefers a real `subtitle_ru` / `subtitle_en` column
/// when the catalogue grows one; this is the fallback beneath it.
class ProductVocabulary {
  const ProductVocabulary._();

  static const _terms = <String, LocalizedText>{
    // ── Claims ──
    'hypoallergenic': LocalizedText(
        'Gipoallergen', 'Гипоаллергенное', 'Hypoallergenic'),
    'gipoallergen': LocalizedText(
        'Gipoallergen', 'Гипоаллергенное', 'Hypoallergenic'),
    'moisturizing': LocalizedText(
        'Namlantiruvchi', 'Увлажняющее', 'Moisturising'),
    'moisturising': LocalizedText(
        'Namlantiruvchi', 'Увлажняющее', 'Moisturising'),
    'namlantiruvchi': LocalizedText(
        'Namlantiruvchi', 'Увлажняющее', 'Moisturising'),
    'brightening': LocalizedText(
        'Yorqinlashtiruvchi', 'Осветляющее', 'Brightening'),
    'deep cleansing': LocalizedText(
        'Chuqur tozalash', 'Глубокое очищение', 'Deep cleansing'),
    'chuqur tozalash': LocalizedText(
        'Chuqur tozalash', 'Глубокое очищение', 'Deep cleansing'),
    'cleansing': LocalizedText('Tozalovchi', 'Очищающее', 'Cleansing'),
    'tozalovchi': LocalizedText('Tozalovchi', 'Очищающее', 'Cleansing'),
    'soothing': LocalizedText(
        'Tinchlantiruvchi', 'Успокаивающее', 'Soothing'),
    'nourishing': LocalizedText('Oziqlantiruvchi', 'Питательное', 'Nourishing'),
    'anti-aging': LocalizedText.same('Anti-aging'),
    'whitening': LocalizedText('Oqartiruvchi', 'Отбеливающее', 'Whitening'),
    'sensitive skin': LocalizedText(
        'Sezgir teri uchun', 'Для чувствительной кожи', 'For sensitive skin'),
    'all skin types': LocalizedText('Barcha teri turlari uchun',
        'Для всех типов кожи', 'For all skin types'),
    'oxygen bubble mask': LocalizedText('Kislorodli pufakchali niqob',
        'Кислородная пузырьковая маска', 'Oxygen bubble mask'),
    'gentle biphasic remover': LocalizedText('Yumshoq ikki fazali vosita',
        'Мягкое двухфазное средство', 'Gentle biphasic remover'),
    'brightening cleansing foam': LocalizedText("Yorqinlashtiruvchi ko'pik",
        'Осветляющая пенка', 'Brightening cleansing foam'),
    'guruchli tozalovchi penka': LocalizedText("Guruchli tozalovchi ko'pik",
        'Рисовая очищающая пенка', 'Rice cleansing foam'),
    'cleansing foam': LocalizedText(
        "Tozalovchi ko'pik", 'Очищающая пенка', 'Cleansing foam'),
    'sun cream': LocalizedText(
        'Quyoshdan himoya kremi', 'Солнцезащитный крем', 'Sun cream'),
    'toner': LocalizedText('Toner', 'Тоник', 'Toner'),
    'serum': LocalizedText('Serum', 'Сыворотка', 'Serum'),
    'ampoule': LocalizedText('Ampula', 'Ампула', 'Ampoule'),
    'mask': LocalizedText('Niqob', 'Маска', 'Mask'),
    'cream': LocalizedText('Krem', 'Крем', 'Cream'),
    'peeling gel': LocalizedText(
        'Piling geli', 'Пилинг-гель', 'Peeling gel'),
    'cleansing oil': LocalizedText(
        "Yog'li tozalovchi", 'Гидрофильное масло', 'Cleansing oil'),
  };

  /// Splits on the separators the catalogue uses, translates what it knows and
  /// rebuilds the line with its punctuation intact.
  static LocalizedText translate(String raw) {
    final source = raw.trim();
    if (source.isEmpty) return const LocalizedText.same('');

    // Captures the separators so they can be put back in place.
    final parts = source.split(RegExp(r'(\s*[•|/]\s*)'));
    final separators = RegExp(r'\s*[•|/]\s*')
        .allMatches(source)
        .map((m) => m.group(0)!)
        .toList();

    final uz = <String>[], ru = <String>[], en = <String>[];
    for (final part in parts) {
      final key = part.trim().toLowerCase();
      final hit = _terms[key];
      uz.add(hit?.uz ?? part.trim());
      ru.add(hit?.ru ?? part.trim());
      en.add(hit?.en ?? part.trim());
    }

    String rebuild(List<String> pieces) {
      final buffer = StringBuffer(pieces.first);
      for (var i = 1; i < pieces.length; i++) {
        buffer.write(i - 1 < separators.length ? separators[i - 1] : ' ');
        buffer.write(pieces[i]);
      }
      return buffer.toString();
    }

    return LocalizedText(rebuild(uz), rebuild(ru), rebuild(en));
  }
}
