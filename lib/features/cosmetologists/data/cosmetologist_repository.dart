import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/models/cosmetolog.dart';

class CosmetologistRepository {
  final _col = FirebaseFirestore.instance.collection('cosmetologists');

  Future<List<Cosmetolog>> getCosmetologists() async {
    try {
      final snap = await _col.orderBy('order').get();
      return snap.docs.map(_fromDoc).toList();
    } catch (e, st) {
      AppLogger.error('Failed to load cosmetologists', e, st);
      rethrow;
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
