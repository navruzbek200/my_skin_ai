import 'package:flutter/material.dart';

import 'package:real_beauty_ai/core/l10n/localized_text.dart';

/// One skin concern, with its cause and what to do about it.
///
/// The copy is [LocalizedText] rather than a plain String because this is
/// content, not interface: it is written and reworded on its own schedule, and
/// holding the three languages side by side means a new entry cannot be added
/// with a translation missing.
class SkinProblem {
  const SkinProblem({
    required this.id,
    required this.name,
    required this.cause,
    required this.solution,
    this.note,
    required this.color,
    required this.icon,
    this.imagePath,
  });

  /// Stable across languages and rewordings — this is what the hero animation
  /// tags and the analysis result key off.
  final String id;
  final LocalizedText name;
  final LocalizedText cause;
  final LocalizedText solution;

  /// An aside that reframes the concern rather than treating it. Only some
  /// entries have one, and the card leaves the row out entirely when they do
  /// not.
  final LocalizedText? note;
  final Color color;
  final IconData icon;
  final String? imagePath;
}

const List<SkinProblem> skinProblems = [
  SkinProblem(
    id: 'acne',
    name: LocalizedText('Husnbuzarlar', 'Высыпания', 'Breakouts'),
    cause: LocalizedText(
      "Teri teshikchalari berkilib, yog' va bakteriyalar to'planadi. Gormonlar, stress va qandli ovqatlar kuchaytiradi.",
      'Поры забиваются, в них скапливаются жир и бактерии. Гормоны, стресс и сладкая еда усиливают процесс.',
      'Pores clog and trap oil and bacteria. Hormones, stress and sugary food make it worse.',
    ),
    solution: LocalizedText(
      'Salisilik kislota yoki benzoyl peroksid asosidagi vositalar. Yuzni kuniga 2 marta yuving. Tegmang — yaxshilantirmaydi!',
      'Средства с салициловой кислотой или бензоилпероксидом. Умывайтесь дважды в день. Не трогайте руками — лучше не станет!',
      'Products with salicylic acid or benzoyl peroxide. Wash twice a day. Do not pick — it never helps!',
    ),
    color: Color(0xFF7060AA),
    icon: Icons.face_retouching_natural_outlined,
    imagePath: 'assets/skin_problems/acne.jpg',
  ),
  SkinProblem(
    id: 'dry',
    name: LocalizedText('Qurish', 'Сухость', 'Dryness'),
    cause: LocalizedText(
      "Teridagi namlik yo'qolishi: quruq havo, issiq suv bilan yuvish, spirt asosidagi vositalar.",
      'Кожа теряет влагу: сухой воздух, умывание горячей водой, средства на спирту.',
      'The skin loses moisture: dry air, washing with hot water, alcohol-based products.',
    ),
    solution: LocalizedText(
      "Yuz yuvgandan keyin zudlik bilan gialuron kislota va squalane asosidagi krem surting. Suv ko'proq iching.",
      'Сразу после умывания нанесите крем с гиалуроновой кислотой и скваланом. Пейте больше воды.',
      'Apply a hyaluronic acid and squalane cream straight after washing. Drink more water.',
    ),
    color: Color(0xFF0284C7),
    icon: Icons.water_drop_outlined,
    imagePath: 'assets/skin_problems/dry.jpg',
  ),
  SkinProblem(
    id: 'oily',
    name: LocalizedText("Yog'li teri", 'Жирная кожа', 'Oily skin'),
    cause: LocalizedText(
      "Gormonlar ta'sirida sebotseylar ko'p yog' ishlab chiqaradi. Genetika, issiq iqlim yoki haddan ortiq tozalash ham sabab.",
      'Под действием гормонов сальные железы вырабатывают много себума. Генетика, жаркий климат и избыточное очищение тоже виноваты.',
      'Hormones push the sebaceous glands to overproduce. Genetics, a hot climate and over-cleansing all add to it.',
    ),
    solution: LocalizedText(
      "Yengil gel moisturizer va niasinamid toner. Artib ketmang — teri yanada ko'proq yog' chiqaradi!",
      'Лёгкий гель-увлажнитель и тоник с ниацинамидом. Не вытирайте лицо насухо — кожа начнёт вырабатывать ещё больше жира!',
      'A light gel moisturiser and a niacinamide toner. Do not strip the skin — it only produces more oil in reply!',
    ),
    note: LocalizedText(
      "Yog'li teri bir jihatdan foydali — qarilik belgilari ko'pincha kechroq paydo bo'ladi.",
      'У жирной кожи есть плюс — признаки старения на ней обычно появляются позже.',
      'Oily skin has one advantage — signs of ageing usually show up later on it.',
    ),
    color: Color(0xFF16A34A),
    icon: Icons.spa_outlined,
    imagePath: 'assets/skin_problems/oily.jpg',
  ),
  SkinProblem(
    id: 'sensitivity',
    name: LocalizedText('Qizarish', 'Покраснение', 'Redness'),
    cause: LocalizedText(
      "Teri to'sig'i zaif bo'lib, tashqi ta'sirlarga haddan ortiq reaktsiya beradi. Allergen ingredientlar, shamol, sovuq kuchaytiradi.",
      'Барьер кожи ослаблен, и она слишком резко реагирует на внешние факторы. Аллергенные компоненты, ветер и холод усиливают реакцию.',
      'The skin barrier is weak and overreacts to anything outside. Allergenic ingredients, wind and cold all make it worse.',
    ),
    solution: LocalizedText(
      "Minimal ingredientli, parfyumersiz vositalar. Sentin 5 asosidagi krem, azelain kislota. Yangi vositani asta sinab ko'ring.",
      'Средства с коротким составом и без отдушек. Крем с пантенолом, азелаиновая кислота. Новое средство вводите постепенно.',
      'Short ingredient lists, no fragrance. A panthenol cream, azelaic acid. Introduce anything new slowly.',
    ),
    note: LocalizedText(
      "Sezgir teri — teri tipi emas, holat. Parvarish bilan yaxshilanishi mumkin.",
      'Чувствительность — это состояние, а не тип кожи. При правильном уходе она проходит.',
      'Sensitivity is a state, not a skin type. With the right care it can improve.',
    ),
    color: Color(0xFFE11D48),
    icon: Icons.favorite_border_rounded,
    imagePath: 'assets/skin_problems/Redness.jpg',
  ),
  SkinProblem(
    id: 'wrinkles',
    name: LocalizedText(
        'Peshona ajinlari', 'Морщины на лбу', 'Forehead lines'),
    cause: LocalizedText(
      "Mimika (qosh ko'tarish, chiyillatish) + quruqlik + quyosh. Peshona eng tez ajinlanadigan hudud.",
      'Мимика (поднятые брови, прищур) плюс сухость и солнце. Лоб — зона, где морщины появляются раньше всего.',
      'Expression (raised brows, squinting) plus dryness and sun. The forehead is where lines show up first.',
    ),
    solution: LocalizedText(
      'Retinol (kechasi boshlang), peptid kremi va kuchli SPF. Quyosh himoyasi eng muhim oldini olish chorasi.',
      'Ретинол (начинайте с вечера), крем с пептидами и высокий SPF. Защита от солнца — главная профилактика.',
      'Retinol (start at night), a peptide cream and a high SPF. Sun protection is the single biggest preventive step.',
    ),
    color: Color(0xFFB45309),
    icon: Icons.auto_awesome_outlined,
    imagePath: 'assets/skin_problems/forehead wrinkles.jpg',
  ),
  SkinProblem(
    id: 'freckles',
    name: LocalizedText('Sepkillar', 'Веснушки', 'Freckles'),
    cause: LocalizedText(
      "Asosan genetika. Quyosh ta'siri melaninni faollashtiradi — yozda to'qroq, qishda ochroq ko'rinadi.",
      'В основном генетика. Солнце активирует меланин — летом веснушки темнее, зимой светлее.',
      'Mostly genetics. Sun activates melanin — freckles darken in summer and fade in winter.',
    ),
    solution: LocalizedText(
      "SPF asosiy himoya. Vitamin C serum yoritadi. Lekin sepkillar tabiiy va ko'pchilik uchun go'zallik belgisi!",
      'SPF — основная защита. Сыворотка с витамином C осветляет. Но веснушки естественны, и для многих это украшение!',
      'SPF is the main defence. A vitamin C serum brightens. But freckles are natural — and for many people, a feature!',
    ),
    note: LocalizedText(
      "Sepkillar xavfsiz — tibbiy muammo emas.",
      'Веснушки безопасны — это не медицинская проблема.',
      'Freckles are harmless — not a medical problem.',
    ),
    color: Color(0xFFDB2777),
    icon: Icons.grain_outlined,
    imagePath: 'assets/skin_problems/freckles.jpg',
  ),
];
