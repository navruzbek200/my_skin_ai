class Product {
  final String imagePath;
  final String? imageUrl;
  final String brand;
  final String name;
  final String subtitle;
  final String price;
  final String category;
  final List<String> benefits;

  const Product({
    required this.imagePath,
    this.imageUrl,
    required this.brand,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.benefits,
  });
}

final List<Product> products = [
  Product(
    imagePath: 'assets/products/product_1.jpg',
    brand: 'MERIKIT',
    name: 'Cica Perfect Sun Cream',
    subtitle: 'SPF 50+ / PA++++',
    price: '189 000 so\'m',
    category: 'SPF',
    benefits: [
      'SPF 50+ / PA++++ kuchli quyosh himoyasi',
      'CICA kompleks bilan teri tinchlanadi',
      'Yengil va namlovchi formula',
      'Oq dog\' va qorayishning oldini oladi',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_2.jpg',
    brand: 'MERIKIT',
    name: 'Multi Protection Balm',
    subtitle: 'SPF 37 / PA++',
    price: '159 000 so\'m',
    category: 'SPF',
    benefits: [
      'SPF 37 / PA++ quyosh himoyasi',
      'Ko\'p maqsadli ishlatish imkoni',
      'Lablar va teri uchun chuqur namlanish',
      'Yumshoq va silliq teri ta\'minlaydi',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_3.jpg',
    brand: 'erste Liebe',
    name: 'Low pH Madeca Green Creamy Biome Cleansing Foam',
    subtitle: 'Hypoallergenic • 150ml',
    price: '145 000 so\'m',
    category: 'Tozalovchi',
    benefits: [
      'pH 5.5 muvozanat saqlab tozalaydi',
      'Madecassoside bilan teri himoyalanadi',
      'Gipoallergen — sezgir teri uchun ideal',
      'Teri lipid to\'siqini mustahkamlaydi',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_4.jpg',
    brand: 'erste Liebe',
    name: 'Madeca White Creamy Biome Cleansing Foam',
    subtitle: 'Moisturizing • 150ml',
    price: '145 000 so\'m',
    category: 'Tozalovchi',
    benefits: [
      'Teri tonini yorqinlashtiradi',
      'Madecassoside bilan tinchlantiradi',
      'Tozalash jarayonida namlanish ta\'minlanadi',
      'Yumshoq ko\'pikli formula',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_5.jpg',
    brand: 'MERIKIT',
    name: 'O2 Mask Cleanser',
    subtitle: 'Oxygen bubble mask',
    price: '175 000 so\'m',
    category: 'Niqob',
    benefits: [
      'Kislorod pufakchalari g\'ovaklarni chuqur tozalaydi',
      'Teri nafas olishini yaxshilaydi',
      'Qon aylanishini faollashtiradi',
      'Teri rangini tekislaydi',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_7.png',
    brand: 'MERIKIT',
    name: 'Double Peeling Gel',
    subtitle: 'AHA + BHA formula',
    price: '165 000 so\'m',
    category: 'Peeling',
    benefits: [
      'AHA — o\'lik teri hujayralarini olib tashlaydi',
      'BHA — g\'ovaklarni chuqur tozalaydi',
      'Teri yuzasi silliq va yorqin bo\'ladi',
      'Tez-tez ishlatishga mos yumshoq formula',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_8.png',
    brand: 'MERIKIT',
    name: 'One Point Cleansing Oil',
    subtitle: 'Deep cleansing',
    price: '179 000 so\'m',
    category: 'Tozalovchi',
    benefits: [
      'Makiyajni to\'liq eritib tozalaydi',
      'Yog\'-asosli formula teri quritmaydi',
      'Ikki bosqichli tozalash samarasini beradi',
      'G\'ovaklar ichidagi kertiklarni olib tashlaydi',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_9.webp',
    brand: 'MERIKIT',
    name: 'Grain Rice Foam',
    subtitle: 'Brightening cleansing foam',
    price: '149 000 so\'m',
    category: 'Tozalovchi',
    benefits: [
      'Guruch ekstrakti teri tonini yorqinlashtiradi',
      'Aminokislotalar teri elastikligini oshiradi',
      'Yumshoq tozalash — teri qurimaydi',
      'Teri yuzasini silliqlashtiradi',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_11.png',
    brand: 'Dr.Itch',
    name: 'pH Balanced Cleansing Foam',
    subtitle: 'Hypoallergenic • 150ml',
    price: '135 000 so\'m',
    category: 'Tozalovchi',
    benefits: [
      'pH balansi saqlab yuzni yumshoq tozalaydi',
      'Gipoallergen formula — sezgir teri uchun ideal',
      'Akne va qizarishni oldini oladi',
      'Teri namligini saqlab qoladi',
    ],
  ),
  Product(
    imagePath: 'assets/products/product_10.png',
    brand: 'MERIKIT',
    name: 'Rose Waterproof Lip & Eye Remover',
    subtitle: 'Gentle biphasic remover',
    price: '155 000 so\'m',
    category: 'Remover',
    benefits: [
      'Ko\'z va lab makiyajini to\'liq olib tashlaydi',
      'Ikki fazali formula — aralashtirib ishlatiladi',
      'Atirgul suvi bilan teri tinchlaydi',
      'Ko\'z atrofi terisini himoya qiladi',
    ],
  ),
];
