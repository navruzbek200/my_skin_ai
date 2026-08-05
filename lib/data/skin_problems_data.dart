import 'package:flutter/material.dart';

class SkinProblem {
  final String id;
  final String name;
  final String cause;
  final String solution;
  final String? note;
  final Color color;
  final IconData icon;
  final String? imagePath;

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
}

const List<SkinProblem> skinProblems = [
  SkinProblem(
    id: 'acne',
    name: 'Husnbuzarlar',
    cause:
        'Teri teshikchalari berkilib, yog\' va bakteriyalar to\'planadi. Gormonlar, stress va qandli ovqatlar kuchaytiradi.',
    solution:
        'Salisilik kislota yoki benzoyl peroksid asosidagi vositalar. Yuzni kuniga 2 marta yuving. Tegmang — yaxshilantirmaydi!',
    color: Color(0xFF7060AA),
    icon: Icons.face_retouching_natural_outlined,
    imagePath: 'assets/skin_problems/acne.jpg',
  ),
  SkinProblem(
    id: 'dry',
    name: 'Qurish',
    cause:
        'Teridagi namlik yo\'qolishi: quruq havo, issiq suv bilan yuvish, spirt asosidagi vositalar.',
    solution:
        'Yuz yuvgandan keyin zudlik bilan gialuron kislota va squalane asosidagi krem surting. Suv ko\'proq iching.',
    color: Color(0xFF0284C7),
    icon: Icons.water_drop_outlined,
    imagePath: 'assets/skin_problems/dry.jpg',
  ),
  SkinProblem(
    id: 'oily',
    name: 'Yog\'li teri',
    cause:
        'Gormonlar ta\'sirida sebotseylar ko\'p yog\' ishlab chiqaradi. Genetika, issiq iqlim yoki haddan ortiq tozalash ham sabab.',
    solution:
        'Yengil gel moisturizer va niasinamid toner. Artib ketmang — teri yanada ko\'proq yog\' chiqaradi!',
    note: 'Yog\'li teri bir jihatdan foydali — qarilik belgilari ko\'pincha kechroq paydo bo\'ladi.',
    color: Color(0xFF16A34A),
    icon: Icons.spa_outlined,
    imagePath: 'assets/skin_problems/oily.jpg',
  ),
  SkinProblem(
    id: 'sensitivity',
    name: 'Qizarish',
    cause:
        'Teri to\'sig\'i zaif bo\'lib, tashqi ta\'sirlarga haddan ortiq reaktsiya beradi. Allergen ingredientlar, shamol, sovuq kuchaytiradi.',
    solution:
        'Minimal ingredientli, parfyumersiz vositalar. Sentin 5 asosidagi krem, azelain kislota. Yangi vositani asta sinab ko\'ring.',
    note: 'Sezgir teri — teri tipi emas, holat. Parvarish bilan yaxshilanishi mumkin.',
    color: Color(0xFFE11D48),
    icon: Icons.favorite_border_rounded,
    imagePath: 'assets/skin_problems/Redness.jpg',
  ),
  SkinProblem(
    id: 'wrinkles',
    name: 'Peshona ajinlari',
    cause:
        'Mimika (qosh ko\'tarish, chiyillatish) + quruqlik + quyosh. Peshona eng tez ajinlanadigan hudud.',
    solution:
        'Retinol (kechasi boshlang), peptid kremi va kuchli SPF. Quyosh himoyasi eng muhim oldini olish chorasi.',
    color: Color(0xFFB45309),
    icon: Icons.auto_awesome_outlined,
    imagePath: 'assets/skin_problems/forehead wrinkles.jpg',
  ),
  SkinProblem(
    id: 'freckles',
    name: 'Sepkillar',
    cause:
        'Asosan genetika. Quyosh ta\'siri melaninni faollashtiradi — yozda to\'qroq, qishda ochroq ko\'rinadi.',
    solution:
        'SPF asosiy himoya. Vitamin C serum yoritadi. Lekin sepkillar tabiiy va ko\'pchilik uchun go\'zallik belgisi!',
    note: 'Sepkillar xavfsiz — tibbiy muammo emas.',
    color: Color(0xFFDB2777),
    icon: Icons.grain_outlined,
    imagePath: 'assets/skin_problems/freckles.jpg',
  ),
];
