import 'package:real_beauty_ai/core/l10n/localized_text.dart';

class Product {
  final String imagePath;
  final String? imageUrl;

  /// Half-width copy used by the grid. A 1400px file is four times the pixels
  /// a 2-column cell can show, so fetching and decoding it 54 times is what
  /// made fast scrolling stall.
  final String? thumbUrl;
  /// Brand and product name are the same on the tube in every market, so they
  /// are plain strings — translating them would make the app and the shelf
  /// disagree.
  final String brand;
  final String name;

  /// The line under the name — a claim ("SPF 50+ / PA++++") or a short
  /// description, which is why it can differ per language.
  final LocalizedText subtitle;
  final String price;

  /// The Firestore filing key, never shown. See `labelForCategory`.
  final String category;
  final List<LocalizedText> benefits;

  const Product({
    required this.imagePath,
    this.imageUrl,
    this.thumbUrl,
    required this.brand,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.benefits,
  });
}

/// Offline fallback for the products screen — shown when Firestore is
/// unreachable and has nothing cached, i.e. a first launch with no network.
///
/// Categories must be drawn from the same set as CATEGORIES in
/// tools/build_products.py, because the filter chips are built from that list.
/// A product filed under anything else is reachable from "Barchasi" only, and
/// on this list that meant every other chip came up empty offline.
final List<Product> products = [
  const Product(
    imagePath: 'assets/products/product_1.jpg',
    brand: 'MERIKIT',
    name: 'Cica Perfect Sun Cream',
    subtitle: LocalizedText.same('SPF 50+ / PA++++'),
    price: "189 000 so'm",
    category: 'Himoya',
    benefits: [
      LocalizedText(
        'SPF 50+ / PA++++ kuchli quyosh himoyasi',
        'SPF 50+ / PA++++ — сильная защита от солнца',
        'SPF 50+ / PA++++ high sun protection',
      ),
      LocalizedText(
        'CICA kompleks bilan teri tinchlanadi',
        'Комплекс CICA успокаивает кожу',
        'The CICA complex calms the skin',
      ),
      LocalizedText(
        'Yengil va namlovchi formula',
        'Лёгкая увлажняющая формула',
        'A light, hydrating formula',
      ),
      LocalizedText(
        "Oq dog' va qorayishning oldini oladi",
        'Предотвращает белые пятна и потемнения',
        'Prevents white patches and darkening',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_2.jpg',
    brand: 'MERIKIT',
    name: 'Multi Protection Balm',
    subtitle: LocalizedText.same('SPF 37 / PA++'),
    price: "159 000 so'm",
    category: 'Himoya',
    benefits: [
      LocalizedText(
        'SPF 37 / PA++ quyosh himoyasi',
        'SPF 37 / PA++ — защита от солнца',
        'SPF 37 / PA++ sun protection',
      ),
      LocalizedText(
        "Ko'p maqsadli ishlatish imkoni",
        'Подходит для нескольких задач сразу',
        'Works for several jobs at once',
      ),
      LocalizedText(
        'Lablar va teri uchun chuqur namlanish',
        'Глубокое увлажнение для губ и кожи',
        'Deep hydration for lips and skin',
      ),
      LocalizedText(
        "Yumshoq va silliq teri ta'minlaydi",
        'Делает кожу мягкой и гладкой',
        'Leaves skin soft and smooth',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_3.jpg',
    brand: 'erste Liebe',
    name: 'Low pH Madeca Green Creamy Biome Cleansing Foam',
    subtitle: LocalizedText(
      'Gipoallergen • 150ml',
      'Гипоаллергенная • 150 мл',
      'Hypoallergenic • 150ml',
    ),
    price: "145 000 so'm",
    category: 'Tozalovchi',
    benefits: [
      LocalizedText(
        'pH 5.5 muvozanat saqlab tozalaydi',
        'Очищает, сохраняя баланс pH 5.5',
        'Cleanses while holding pH at 5.5',
      ),
      LocalizedText(
        'Madecassoside bilan teri himoyalanadi',
        'Мадекассозид защищает кожу',
        'Madecassoside protects the skin',
      ),
      LocalizedText(
        'Gipoallergen — sezgir teri uchun ideal',
        'Гипоаллергенная — идеально для чувствительной кожи',
        'Hypoallergenic — ideal for sensitive skin',
      ),
      LocalizedText(
        "Teri lipid to'siqini mustahkamlaydi",
        'Укрепляет липидный барьер кожи',
        'Strengthens the skin lipid barrier',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_4.jpg',
    brand: 'erste Liebe',
    name: 'Madeca White Creamy Biome Cleansing Foam',
    subtitle: LocalizedText(
      'Namlantiruvchi • 150ml',
      'Увлажняющая • 150 мл',
      'Moisturising • 150ml',
    ),
    price: "145 000 so'm",
    category: 'Tozalovchi',
    benefits: [
      LocalizedText(
        'Teri tonini yorqinlashtiradi',
        'Выравнивает и осветляет тон кожи',
        'Brightens the skin tone',
      ),
      LocalizedText(
        'Madecassoside bilan tinchlantiradi',
        'Мадекассозид успокаивает кожу',
        'Madecassoside soothes the skin',
      ),
      LocalizedText(
        "Tozalash jarayonida namlanish ta'minlanadi",
        'Увлажняет прямо во время очищения',
        'Hydrates while it cleanses',
      ),
      LocalizedText(
        "Yumshoq ko'pikli formula",
        'Мягкая пенная формула',
        'A gentle foaming formula',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_5.jpg',
    brand: 'MERIKIT',
    name: 'O2 Mask Cleanser',
    subtitle: LocalizedText(
      'Kislorodli pufakchali niqob',
      'Кислородная пузырьковая маска',
      'Oxygen bubble mask',
    ),
    price: "175 000 so'm",
    category: 'Niqob',
    benefits: [
      LocalizedText(
        "Kislorod pufakchalari g'ovaklarni chuqur tozalaydi",
        'Кислородные пузырьки глубоко очищают поры',
        'Oxygen bubbles clean deep into the pores',
      ),
      LocalizedText(
        'Teri nafas olishini yaxshilaydi',
        'Кожа начинает лучше дышать',
        'Lets the skin breathe better',
      ),
      LocalizedText(
        'Qon aylanishini faollashtiradi',
        'Активизирует кровообращение',
        'Boosts circulation',
      ),
      LocalizedText(
        'Teri rangini tekislaydi',
        'Выравнивает цвет лица',
        'Evens out the complexion',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_7.png',
    brand: 'MERIKIT',
    name: 'Double Peeling Gel',
    subtitle: LocalizedText.same('AHA + BHA'),
    price: "165 000 so'm",
    category: 'Tozalovchi',
    benefits: [
      LocalizedText(
        "AHA — o'lik teri hujayralarini olib tashlaydi",
        'AHA — удаляет отмершие клетки кожи',
        'AHA — lifts away dead skin cells',
      ),
      LocalizedText(
        "BHA — g'ovaklarni chuqur tozalaydi",
        'BHA — глубоко очищает поры',
        'BHA — cleans deep into the pores',
      ),
      LocalizedText(
        "Teri yuzasi silliq va yorqin bo'ladi",
        'Кожа становится гладкой и сияющей',
        'Leaves the surface smooth and bright',
      ),
      LocalizedText(
        'Tez-tez ishlatishga mos yumshoq formula',
        'Мягкая формула для регулярного применения',
        'A gentle formula, fine for regular use',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_8.png',
    brand: 'MERIKIT',
    name: 'One Point Cleansing Oil',
    subtitle: LocalizedText(
      'Chuqur tozalash',
      'Глубокое очищение',
      'Deep cleansing',
    ),
    price: "179 000 so'm",
    category: 'Tozalovchi',
    benefits: [
      LocalizedText(
        "Makiyajni to'liq eritib tozalaydi",
        'Полностью растворяет макияж',
        'Dissolves makeup completely',
      ),
      LocalizedText(
        "Yog'-asosli formula teri quritmaydi",
        'Масляная формула не сушит кожу',
        'An oil base that will not dry the skin out',
      ),
      LocalizedText(
        'Ikki bosqichli tozalash samarasini beradi',
        'Даёт эффект двухэтапного очищения',
        'Gives the effect of a two-step cleanse',
      ),
      LocalizedText(
        "G'ovaklar ichidagi kertiklarni olib tashlaydi",
        'Убирает загрязнения изнутри пор',
        'Clears build-up out of the pores',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_9.webp',
    brand: 'MERIKIT',
    name: 'Grain Rice Foam',
    subtitle: LocalizedText(
      "Yorqinlashtiruvchi ko'pik",
      'Осветляющая пенка',
      'Brightening cleansing foam',
    ),
    price: "149 000 so'm",
    category: 'Tozalovchi',
    benefits: [
      LocalizedText(
        'Guruch ekstrakti teri tonini yorqinlashtiradi',
        'Экстракт риса осветляет тон кожи',
        'Rice extract brightens the skin tone',
      ),
      LocalizedText(
        'Aminokislotalar teri elastikligini oshiradi',
        'Аминокислоты повышают упругость кожи',
        'Amino acids improve elasticity',
      ),
      LocalizedText(
        'Yumshoq tozalash — teri qurimaydi',
        'Мягкое очищение — кожа не пересушивается',
        'A gentle cleanse — the skin does not dry out',
      ),
      LocalizedText(
        'Teri yuzasini silliqlashtiradi',
        'Разглаживает поверхность кожи',
        'Smooths the surface of the skin',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_11.png',
    brand: 'Dr.Itch',
    name: 'pH Balanced Cleansing Foam',
    subtitle: LocalizedText(
      'Gipoallergen • 150ml',
      'Гипоаллергенная • 150 мл',
      'Hypoallergenic • 150ml',
    ),
    price: "135 000 so'm",
    category: 'Tozalovchi',
    benefits: [
      LocalizedText(
        'pH balansi saqlab yuzni yumshoq tozalaydi',
        'Мягко очищает, сохраняя баланс pH',
        'Cleanses gently, keeping the pH in balance',
      ),
      LocalizedText(
        'Gipoallergen formula — sezgir teri uchun ideal',
        'Гипоаллергенная формула — идеально для чувствительной кожи',
        'A hypoallergenic formula — ideal for sensitive skin',
      ),
      LocalizedText(
        'Akne va qizarishni oldini oladi',
        'Предотвращает высыпания и покраснения',
        'Helps prevent breakouts and redness',
      ),
      LocalizedText(
        'Teri namligini saqlab qoladi',
        'Сохраняет увлажнённость кожи',
        'Keeps the skin hydrated',
      ),
    ],
  ),
  const Product(
    imagePath: 'assets/products/product_10.png',
    brand: 'MERIKIT',
    name: 'Rose Waterproof Lip & Eye Remover',
    subtitle: LocalizedText(
      'Yumshoq ikki fazali vosita',
      'Мягкое двухфазное средство',
      'Gentle biphasic remover',
    ),
    price: "155 000 so'm",
    category: 'Tozalovchi',
    benefits: [
      LocalizedText(
        "Ko'z va lab makiyajini to'liq olib tashlaydi",
        'Полностью снимает макияж с глаз и губ',
        'Removes eye and lip makeup completely',
      ),
      LocalizedText(
        'Ikki fazali formula — aralashtirib ishlatiladi',
        'Двухфазная формула — взболтайте перед использованием',
        'A two-phase formula — shake before use',
      ),
      LocalizedText(
        'Atirgul suvi bilan teri tinchlaydi',
        'Розовая вода успокаивает кожу',
        'Rose water calms the skin',
      ),
      LocalizedText(
        "Ko'z atrofi terisini himoya qiladi",
        'Защищает нежную кожу вокруг глаз',
        'Protects the delicate skin around the eyes',
      ),
    ],
  ),
];
