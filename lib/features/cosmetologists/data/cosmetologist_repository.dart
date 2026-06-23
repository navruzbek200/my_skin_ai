import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/models/cosmetolog.dart';

class CosmetologistRepository {
  final _col = FirebaseFirestore.instance.collection('cosmetologists');

  Future<List<Cosmetolog>> getCosmetologists() async {
    try {
      final snap = await _col.orderBy('order').get();
      if (snap.docs.isEmpty) return _seed;
      return snap.docs.map(_fromDoc).toList();
    } catch (e, st) {
      AppLogger.error('Failed to load cosmetologists', e, st);
      return _seed;
    }
  }

  Cosmetolog _fromDoc(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawColors = (d['gradientColors'] as List<dynamic>?)?.cast<String>() ?? [];
    final colors = rawColors.length >= 2
        ? rawColors.map((h) => Color(int.parse(h))).toList()
        : [const Color(0xFFD4D4F0), const Color(0xFF9090C8)];
    return Cosmetolog(
      name: d['name'] ?? '',
      title: d['title'] ?? '',
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 0,
      distance: d['distance'] ?? '',
      city: d['city'] ?? '',
      bio: d['bio'] ?? '',
      specialties: List<String>.from(d['specialties'] ?? []),
      verified: d['verified'] ?? false,
      nextSlot: d['nextSlot'] ?? '',
      gradientColors: colors,
      filterTag: d['filterTag'] ?? '',
      phone: d['phone'] ?? '',
      telegram: d['telegram'] ?? '',
      instagram: d['instagram'] ?? '',
      experienceYears: (d['experienceYears'] as num?)?.toInt() ?? 0,
      photoUrl: d['photoUrl'] as String?,
    );
  }
}

const _seed = [
  Cosmetolog(
    name: 'Dr. Malika Yusupova', title: 'Dermatolog, MD',
    rating: 4.9, reviewCount: 312, distance: '0.6 km',
    city: 'Toshkent · Yunusobod',
    bio: "Melanin-boy teri mutaxassisi. 10 yillik klinik tajriba. Teri to'sig'ini hurmat qilgan holda aniq muolajalar belgilaydi.",
    specialties: ['Pigmentatsiya', 'Rozatsea', 'Anti-aging'],
    verified: true, nextSlot: 'Bugun · 16:30',
    gradientColors: [Color(0xFFEFD9D2), Color(0xFFC9A8A0)],
    filterTag: 'Dermatolog',
    phone: '+998 90 123 45 67', telegram: '@dr_malika_uz',
    instagram: '@dr.malika.skin', experienceYears: 10,
  ),
  Cosmetolog(
    name: 'Nilufar Rashidova', title: 'Facialist',
    rating: 4.85, reviewCount: 240, distance: '1.2 km',
    city: 'Toshkent · Chilonzor',
    bio: "12 yillik klinik va tahririyat tajribasi bilan litsenziyalangan facialist. Har bir yuzni butun holda o'qiydi.",
    specialties: ['Yuz tozalash', 'Gua sha', 'Akne parvarishi'],
    verified: true, nextSlot: 'Ertaga · 11:00',
    gradientColors: [Color(0xFFD4E4D2), Color(0xFF8FAE8A)],
    filterTag: 'Facialist',
    phone: '+998 91 234 56 78', telegram: '@nilufar_facialist',
    instagram: '@nilufar.glow', experienceYears: 12,
  ),
  Cosmetolog(
    name: 'Bobur Toshmatov', title: 'Kosmetic kimyogar',
    rating: 4.7, reviewCount: 86, distance: '2.1 km',
    city: "Toshkent · Mirzo Ulug'bek",
    bio: "Maxsus formulalar va individual rutinani ko'rib chiqish bo'yicha maslahat beradi. Tokchangizni olib keling — yarim kichikroq ro'yxat bilan ketasiz.",
    specialties: ['Maxsus formulalar', "Rutinani ko'rib chiqish"],
    verified: true, nextSlot: 'Dushanba · 10:00',
    gradientColors: [Color(0xFFD2D8DE), Color(0xFF8E97A2)],
    filterTag: 'Estetik',
    phone: '+998 93 345 67 89', telegram: '@bobur_chem',
    instagram: '@bobur.cosmetics', experienceYears: 6,
  ),
  Cosmetolog(
    name: 'Sarvinoz Karimova', title: 'Estetik mutaxassis',
    rating: 4.8, reviewCount: 198, distance: '3.8 km',
    city: 'Toshkent · Shayxontohur',
    bio: "Parijda tahsil olgan, aniq va sust muolajalar bo'yicha mutaxassis. Bir martalik tuzatish emas, uzoq muddatli rituallarni rejalashtiruvchilar uchun eng yaxshi.",
    specialties: ['Tozalash', 'Mikroneedling', 'Limfatik drenaj'],
    verified: false, nextSlot: 'Juma · 14:00',
    gradientColors: [Color(0xFFA5BCA0), Color(0xFF5E7E5A)],
    filterTag: 'Estetik',
    phone: '+998 97 456 78 90', telegram: '@sarvinoz_estetik',
    instagram: '@sarvinoz.beauty', experienceYears: 8,
  ),
  Cosmetolog(
    name: 'Dr. Timur Ergashev', title: 'Tibbiy estetik',
    rating: 4.9, reviewCount: 412, distance: '1.7 km',
    city: 'Toshkent · Yakkasaroy',
    bio: "Ifodani saqlovchi konservativ muolajalar. Kerak bo'lmasa davolamaslikni maslahat beradi. 14 yillik tibbiy tajriba.",
    specialties: ['Inyeksiyalar', 'Teri kuchaytiruvchi', 'PRF'],
    verified: true, nextSlot: 'Bugun · 18:00',
    gradientColors: [Color(0xFFE2CDB0), Color(0xFFA89074)],
    filterTag: 'Injeksion',
    phone: '+998 99 567 89 01', telegram: '@dr_timur_estetik',
    instagram: '@dr.timur.aesthetic', experienceYears: 14,
  ),
  Cosmetolog(
    name: 'Jasur Mirzayev', title: 'Holistic facialist',
    rating: 4.75, reviewCount: 160, distance: '0.9 km',
    city: 'Toshkent · Mirabad',
    bio: "Botanik asosli amaliyot, sekin va sezgir ish. Stress-pattern teri va nafas olishga muhtoj bo'lganlar uchun eng yaxshi.",
    specialties: ['Botanik facials', 'Massaj', 'Kaping'],
    verified: true, nextSlot: "Chorshanba · 9:30",
    gradientColors: [Color(0xFFD4D4F0), Color(0xFF9090C8)],
    filterTag: 'Facialist',
    phone: '+998 94 678 90 12', telegram: '@jasur_holistic',
    instagram: '@jasur.skin', experienceYears: 5,
  ),
];
