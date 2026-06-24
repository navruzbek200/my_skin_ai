import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_beauty_ai/data/products_data.dart';

/// Concern name (matches SkinConcern.name) → relevant product categories.
const _concernToCategories = <String, List<String>>{
  'acne':        ['Tozalovchi', 'Niqob'],
  'darkSpots':   ['Peeling', 'Tozalovchi'],
  'pores':       ['Niqob', 'Peeling'],
  'wrinkles':    ['SPF'],
  'darkCircles': ['Tozalovchi', 'Remover'],
  'eyeBags':     ['Remover'],
  'blackheads':  ['Niqob', 'Peeling'],
  'oiliness':    ['Tozalovchi', 'SPF'],
};

class ProductRepository {
  final _col = FirebaseFirestore.instance.collection('products');

  Future<List<Product>> getProducts() async {
    try {
      final snap = await _col.orderBy('order').get();
      if (snap.docs.isEmpty) return products;
      return snap.docs.map(_fromDoc).toList();
    } catch (_) {
      return products;
    }
  }

  /// Returns up to [limit] products most relevant to the given concern keys.
  /// Falls back gracefully — never throws.
  Future<List<Product>> getRecommendedForConcerns(
    Set<String> concerns, {
    int limit = 4,
  }) async {
    if (concerns.isEmpty) return [];
    try {
      final all = await getProducts();

      // Collect relevant categories preserving priority order
      final relevantCats = <String>{};
      for (final c in concerns) {
        relevantCats.addAll(_concernToCategories[c] ?? []);
      }

      final matched = all.where((p) => relevantCats.contains(p.category)).toList();

      // Score each product by how many relevant categories it satisfies
      matched.sort((a, b) {
        final aScore = relevantCats.contains(a.category) ? 1 : 0;
        final bScore = relevantCats.contains(b.category) ? 1 : 0;
        return bScore - aScore;
      });

      return matched.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  Product _fromDoc(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Product(
      imagePath: d['imagePath'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      brand: d['brand'] as String? ?? '',
      name: d['name'] as String? ?? '',
      subtitle: d['subtitle'] as String? ?? '',
      price: d['price'] as String? ?? '',
      category: d['category'] as String? ?? '',
      benefits: List<String>.from(d['benefits'] as List? ?? []),
    );
  }
}
