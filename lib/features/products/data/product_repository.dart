import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/data/products_data.dart';

/// Concern name (matches SkinConcern.name) → relevant product categories.
/// Categories are the brand's product lines; see the chips in products_page.
class ProductRepository {
  /// Resolved on use, not in the constructor. `FirebaseFirestore.instance`
  /// throws when no Firebase app exists, and as a field initialiser that made
  /// merely *constructing* a repository fatal — which meant any screen holding
  /// one could not be widget-tested, and a degraded launch (Firebase init
  /// failed, see main.dart) crashed instead of falling back to the bundled
  /// list. Inside the getter the throw lands in the callers' catch.
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('products');

  Future<List<Product>> getProducts() async {
    try {
      final snap = await _col.orderBy('order').get();
      if (snap.docs.isEmpty) return products;
      return snap.docs.map(_fromDoc).toList();
    } catch (_) {
      return products;
    }
  }

  Product _fromDoc(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Product(
      imagePath: d['imagePath'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      thumbUrl: d['thumbUrl'] as String?,
      brand: d['brand'] as String? ?? '',
      name: d['name'] as String? ?? '',
      subtitle: _text(d, 'subtitle'),
      price: d['price'] as String? ?? '',
      category: d['category'] as String? ?? '',
      benefits: _textList(d, 'benefits'),
    );
  }

  /// Reads a translated field the way the catalogue is actually written.
  ///
  /// The buyer's tooling has always written a single Uzbek `subtitle`, and
  /// documents already in Firestore still look like that. Rather than require
  /// a migration before the app can ship in three languages, an optional
  /// `subtitle_ru` / `subtitle_en` is used when present and the Uzbek value
  /// stands in when it is not — so an untranslated product reads in Uzbek
  /// instead of showing a blank line.
  static LocalizedText _text(Map<String, dynamic> d, String key) {
    final uz = d[key] as String? ?? '';
    return LocalizedText(
      uz,
      d['${key}_ru'] as String? ?? uz,
      d['${key}_en'] as String? ?? uz,
    );
  }

  /// The same fallback, for the bulleted benefits.
  ///
  /// The translated lists have to line up item for item with the Uzbek one; a
  /// list of a different length is treated as absent rather than zipped
  /// against the wrong bullets.
  static List<LocalizedText> _textList(Map<String, dynamic> d, String key) {
    final uz = List<String>.from(d[key] as List? ?? const []);
    List<String>? sibling(String suffix) {
      final raw = d['${key}_$suffix'] as List?;
      if (raw == null) return null;
      final list = List<String>.from(raw);
      return list.length == uz.length ? list : null;
    }

    final ru = sibling('ru');
    final en = sibling('en');
    return [
      for (var i = 0; i < uz.length; i++)
        LocalizedText(uz[i], ru?[i] ?? uz[i], en?[i] ?? uz[i]),
    ];
  }
}
