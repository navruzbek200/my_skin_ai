import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:real_beauty_ai/data/products_data.dart';

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
