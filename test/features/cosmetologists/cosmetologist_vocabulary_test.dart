import 'package:flutter_test/flutter_test.dart';
import 'package:real_beauty_ai/data/cosmetologist_vocabulary.dart';
import 'package:real_beauty_ai/l10n/app_localizations_en.dart';
import 'package:real_beauty_ai/l10n/app_localizations_ru.dart';
import 'package:real_beauty_ai/l10n/app_localizations_uz.dart';

/// The specialist directory is authored in Uzbek in Firestore with no
/// translated columns, so without this table the whole section stayed Uzbek
/// whatever language the app was in.
void main() {
  group('cosmetologistTerm', () {
    test('translates the titles the directory actually uses', () {
      expect(cosmetologistTerm('Kosmetolog').ru, 'Косметолог');
      expect(cosmetologistTerm('Kosmetolog').en, 'Cosmetologist');
      expect(cosmetologistTerm('Dermatolog-kosmetolog').ru,
          'Дерматолог-косметолог');
      expect(cosmetologistTerm('Inyeksion kosmetolog').en,
          'Injectables specialist');
    });

    test('translates the places the directory actually uses', () {
      expect(cosmetologistTerm('Toshkent').ru, 'Ташкент');
      expect(cosmetologistTerm('Toshkent shahri').en, 'Tashkent city');
      expect(cosmetologistTerm('Qibray tumani').ru, 'Кибрайский район');
    });

    test('is case- and whitespace-insensitive', () {
      // The directory is typed by hand, so "Toshkent shahri" and
      // "toshkent  shahri" are the same place.
      expect(cosmetologistTerm('  TOSHKENT   SHAHRI ').ru, 'город Ташкент');
      expect(cosmetologistTerm('kOsMeToLoG').en, 'Cosmetologist');
    });

    test('an unknown term falls through readable rather than blank', () {
      // A title added to the directory tomorrow shows in Uzbek — wrong, but
      // legible. Returning an empty string would blank the card instead.
      final unknown = cosmetologistTerm('Podolog');
      expect(unknown.uz, 'Podolog');
      expect(unknown.ru, 'Podolog');
      expect(unknown.en, 'Podolog');
    });

    test('trims what it passes through', () {
      expect(cosmetologistTerm('  Podolog  ').uz, 'Podolog');
    });
  });

  group('cosmetologistFilters', () {
    test('the first chip clears the filter rather than naming a tag', () {
      // Matched against `filterTag`, and an empty key means "everything".
      expect(cosmetologistFilters.first.key, '');
    });

    test('every key is distinct, or two chips would show the same people', () {
      final keys = cosmetologistFilters.map((f) => f.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('every chip is labelled in all three languages', () {
      final uz = AppLocalizationsUz();
      final ru = AppLocalizationsRu();
      final en = AppLocalizationsEn();
      for (final f in cosmetologistFilters) {
        expect(f.label(uz).trim(), isNotEmpty);
        expect(f.label(ru).trim(), isNotEmpty);
        expect(f.label(en).trim(), isNotEmpty);
      }
    });

    test('the keys stay Uzbek so Firestore matching survives a switch', () {
      // The label changes with the language; the key must not, or every chip
      // comes up empty the moment somebody reads the app in Russian.
      final ru = AppLocalizationsRu();
      final dermatologist =
          cosmetologistFilters.firstWhere((f) => f.key == 'Dermatolog');
      expect(dermatologist.label(ru), 'Дерматолог');
      expect(dermatologist.key, 'Dermatolog');
    });
  });
}
