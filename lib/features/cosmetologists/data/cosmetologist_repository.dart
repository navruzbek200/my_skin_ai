import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_beauty_ai/core/l10n/localized_text.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/data/cosmetologist_vocabulary.dart';
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
      title: _text(d, 'title'),
      rating: (d['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 0,
      distance: d['distance'] ?? '',
      city: _text(d, 'city'),
      bio: _text(d, 'bio'),
      specialties: _textList(d, 'specialties'),
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

  /// Reads a directory field in three languages.
  ///
  /// The directory has always held a single Uzbek value per field, and the
  /// records already in Firestore still look like that. Rather than require a
  /// migration before the app can show specialists in Russian, an optional
  /// `title_ru` / `title_en` is used when present, and otherwise the value is
  /// looked up in the local vocabulary — which covers the professional titles
  /// and districts this directory actually uses. Anything unknown falls
  /// through in Uzbek, which is wrong but readable, and never blank.
  static LocalizedText _text(Map<String, dynamic> d, String key) {
    final uz = (d[key] as String? ?? '').trim();
    if (uz.isEmpty) return const LocalizedText.same('');
    final fallback = cosmetologistTerm(uz);
    return LocalizedText(
      uz,
      d['${key}_ru'] as String? ?? fallback.ru,
      d['${key}_en'] as String? ?? fallback.en,
    );
  }

  /// The same, for the list of focus areas.
  ///
  /// A translated list of a different length is treated as absent rather than
  /// zipped against the wrong entries.
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
        () {
          final fallback = cosmetologistTerm(uz[i]);
          return LocalizedText(
              uz[i], ru?[i] ?? fallback.ru, en?[i] ?? fallback.en);
        }(),
    ];
  }
}
