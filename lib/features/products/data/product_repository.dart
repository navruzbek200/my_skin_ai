import 'package:cloud_firestore/cloud_firestore.dart';
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
      subtitle: d['subtitle'] as String? ?? '',
      price: d['price'] as String? ?? '',
      category: d['category'] as String? ?? '',
      benefits: List<String>.from(d['benefits'] as List? ?? []),
    );
  }
}
