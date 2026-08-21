import 'package:real_beauty_ai/core/l10n/localized_text.dart';

/// A filter chip on the products screen.
///
/// The key and the label are deliberately separate. The key is the string
/// Firestore files each product under — it is Uzbek because that is what the
/// buyer's tooling writes (see `CATEGORIES` in `tools/build_products.py`) — and
/// it must not change with the interface language, or every chip would come up
/// empty the moment somebody switched to Russian.
class ProductCategory {
  const ProductCategory({required this.key, required this.label});

  /// Matches `Product.category`. Never translated, never shown.
  final String key;

  /// What the chip actually says.
  final LocalizedText label;
}

/// `null` key means "everything" — the chip that clears the filter rather than
/// naming a line.
const ProductCategory allProductsCategory = ProductCategory(
  key: '',
  label: LocalizedText('Barchasi', 'Все', 'All'),
);

/// Mirrors the brand's own product lines, which is how the catalogue is
/// organised and how customers ask for it. Must stay in step with `CATEGORIES`
/// in `tools/build_products.py` — a product filed under anything else is
/// reachable from the "all" chip only.
const List<ProductCategory> productCategories = [
  allProductsCategory,
  ProductCategory(
    key: 'Tozalovchi',
    label: LocalizedText('Tozalovchi', 'Очищение', 'Cleansers'),
  ),
  ProductCategory(
    key: 'Himoya',
    label: LocalizedText('Himoya', 'Защита', 'Protection'),
  ),
  ProductCategory(
    key: 'Oqartiruvchi',
    label: LocalizedText('Oqartiruvchi', 'Осветление', 'Brightening'),
  ),
  ProductCategory(
    key: 'Tinchlantiruvchi',
    label: LocalizedText('Tinchlantiruvchi', 'Успокаивающие', 'Soothing'),
  ),
  ProductCategory(
    key: 'Ampula',
    label: LocalizedText('Ampula', 'Ампулы', 'Ampoules'),
  ),
  ProductCategory(
    key: 'Namlantiruvchi',
    label: LocalizedText('Namlantiruvchi', 'Увлажнение', 'Moisturisers'),
  ),
  ProductCategory(
    key: 'Stem Cell',
    // The brand prints this line in English on the packaging in every market,
    // so translating it would make the shelf and the app disagree.
    label: LocalizedText.same('Stem Cell'),
  ),
  ProductCategory(
    key: 'Niqob',
    label: LocalizedText('Niqob', 'Маски', 'Masks'),
  ),
  ProductCategory(
    key: 'Tana',
    label: LocalizedText('Tana', 'Для тела', 'Body'),
  ),
];

/// The label for a product's stored category, for the badge on a product card.
/// Falls back to the raw key so a category added to Firestore before it is
/// added here still shows something rather than a blank chip.
LocalizedText labelForCategory(String key) {
  for (final category in productCategories) {
    if (category.key == key) return category.label;
  }
  return LocalizedText.same(key);
}
