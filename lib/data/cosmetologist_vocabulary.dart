import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';

/// A filter chip on the specialists screen.
///
/// Key and label are separate for the same reason as `ProductCategory`: the key
/// is the string Firestore files each specialist under (`filterTag`), it is
/// Uzbek because that is what the buyer's tooling writes, and it must not
/// change with the interface language — or every chip would come up empty the
/// moment somebody switched to Russian.
class CosmetologistFilter {
  const CosmetologistFilter({required this.key, required this.label});

  /// Matches `Cosmetolog.filterTag`. Never translated, never shown.
  /// Empty means "everything".
  final String key;
  final String Function(AppLocalizations) label;
}

const List<CosmetologistFilter> cosmetologistFilters = [
  CosmetologistFilter(key: '', label: _all),
  CosmetologistFilter(key: 'Facialist', label: _facialist),
  CosmetologistFilter(key: 'Dermatolog', label: _dermatologist),
  CosmetologistFilter(key: 'Estetik', label: _aesthetician),
  CosmetologistFilter(key: 'Injeksion', label: _injection),
];

String _all(AppLocalizations l) => l.cosmoFilterAll;
String _facialist(AppLocalizations l) => l.cosmoFilterFacialist;
String _dermatologist(AppLocalizations l) => l.cosmoFilterDermatologist;
String _aesthetician(AppLocalizations l) => l.cosmoFilterAesthetician;
String _injection(AppLocalizations l) => l.cosmoFilterInjection;

/// Job titles and places, as the directory actually writes them.
///
/// The specialist list is authored in Uzbek in Firestore and has no translated
/// columns yet, so without this the whole section stayed Uzbek whatever
/// language the app was in. These are a small closed vocabulary — a handful of
/// professional titles and the districts around Tashkent — so translating them
/// here works today, rather than waiting on a data migration.
///
/// Anything not in the table falls through unchanged: a new title shows in
/// Uzbek, which is wrong but readable, and never blank. The repository also
/// reads optional `title_ru` / `title_en` fields, so the directory can override
/// any of this per record without a code change.
const Map<String, LocalizedText> _vocabulary = {
  // ── Titles ──
  'kosmetolog': LocalizedText('Kosmetolog', 'Косметолог', 'Cosmetologist'),
  'inyeksion kosmetolog': LocalizedText('Inyeksion kosmetolog',
      'Инъекционный косметолог', 'Injectables specialist'),
  'injeksion kosmetolog': LocalizedText('Injeksion kosmetolog',
      'Инъекционный косметолог', 'Injectables specialist'),
  'dermatolog': LocalizedText('Dermatolog', 'Дерматолог', 'Dermatologist'),
  'dermatolog-kosmetolog': LocalizedText('Dermatolog-kosmetolog',
      'Дерматолог-косметолог', 'Dermatologist and cosmetologist'),
  'estetist': LocalizedText('Estetist', 'Эстетист', 'Aesthetician'),
  'estetik kosmetolog': LocalizedText(
      'Estetik kosmetolog', 'Эстетический косметолог', 'Aesthetic cosmetologist'),
  'facialist': LocalizedText.same('Facialist'),
  'massajchi': LocalizedText('Massajchi', 'Массажист', 'Massage therapist'),
  'trixolog': LocalizedText('Trixolog', 'Трихолог', 'Trichologist'),
  'vizajist': LocalizedText('Vizajist', 'Визажист', 'Makeup artist'),

  // ── Places ──
  'toshkent': LocalizedText('Toshkent', 'Ташкент', 'Tashkent'),
  'toshkent shahri': LocalizedText(
      'Toshkent shahri', 'город Ташкент', 'Tashkent city'),
  'toshkent viloyati': LocalizedText(
      'Toshkent viloyati', 'Ташкентская область', 'Tashkent region'),
  'qibray tumani': LocalizedText(
      'Qibray tumani', 'Кибрайский район', 'Qibray district'),
  'chilonzor': LocalizedText('Chilonzor', 'Чиланзар', 'Chilanzar'),
  'yunusobod': LocalizedText('Yunusobod', 'Юнусабад', 'Yunusabad'),
  'mirzo ulug\'bek': LocalizedText(
      "Mirzo Ulug'bek", 'Мирзо-Улугбек', 'Mirzo Ulugbek'),
  'sergeli': LocalizedText('Sergeli', 'Сергели', 'Sergeli'),
  'olmazor': LocalizedText('Olmazor', 'Алмазар', 'Olmazar'),
  'shayxontohur': LocalizedText('Shayxontohur', 'Шайхантахур', 'Shaykhantakhur'),
  'yakkasaroy': LocalizedText('Yakkasaroy', 'Яккасарай', 'Yakkasaray'),
  'samarqand': LocalizedText('Samarqand', 'Самарканд', 'Samarkand'),
  'buxoro': LocalizedText('Buxoro', 'Бухара', 'Bukhara'),
  'andijon': LocalizedText('Andijon', 'Андижан', 'Andijan'),
  'farg\'ona': LocalizedText("Farg'ona", 'Фергана', 'Fergana'),
  'namangan': LocalizedText('Namangan', 'Наманган', 'Namangan'),

  // ── Specialties ──
  'botoks': LocalizedText('Botoks', 'Ботокс', 'Botox'),
  'filler': LocalizedText('Filler', 'Филлеры', 'Fillers'),
  'mezoterapiya': LocalizedText('Mezoterapiya', 'Мезотерапия', 'Mesotherapy'),
  'biorevitalizatsiya': LocalizedText(
      'Biorevitalizatsiya', 'Биоревитализация', 'Biorevitalisation'),
  'pilling': LocalizedText('Pilling', 'Пилинг', 'Peels'),
  'tozalash': LocalizedText('Tozalash', 'Чистка лица', 'Facial cleansing'),
  'lazer': LocalizedText('Lazer', 'Лазер', 'Laser'),
  'akne': LocalizedText('Akne', 'Акне', 'Acne'),
  'anti-aging': LocalizedText.same('Anti-aging'),
  'lifting': LocalizedText('Lifting', 'Лифтинг', 'Lifting'),
  'massaj': LocalizedText('Massaj', 'Массаж', 'Massage'),
  'kontur plastika': LocalizedText(
      'Kontur plastika', 'Контурная пластика', 'Contouring'),
};

/// Looks a directory value up in the table above.
///
/// Matched case- and space-insensitively, because the directory is typed by
/// hand and "Toshkent shahri" and "toshkent  shahri" are the same place.
LocalizedText cosmetologistTerm(String raw) {
  final key = raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  return _vocabulary[key] ?? LocalizedText.same(raw.trim());
}
