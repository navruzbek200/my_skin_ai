import 'package:flutter/material.dart';

import 'package:real_beauty_ai/core/l10n/localized_text.dart';

class Cosmetolog {
  /// A person's name, which is the same in every language.
  final String name;

  /// Job title, place and blurb come out of a Firestore directory written in
  /// Uzbek. They are [LocalizedText] so the screen can show them in whichever
  /// language is on — see `CosmetologistRepository`, which fills the other two
  /// from optional `_ru` / `_en` columns and otherwise from a local vocabulary.
  final LocalizedText title;
  final double rating;
  final int reviewCount;
  final String distance;
  final LocalizedText city;
  final LocalizedText bio;
  final List<LocalizedText> specialties;
  final bool verified;
  final String nextSlot;
  final List<Color> gradientColors;
  final String filterTag;
  final String phone;
  final String telegram;
  final String instagram;
  final int experienceYears;
  final String? photoUrl;

  const Cosmetolog({
    required this.name,
    required this.title,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.city,
    required this.bio,
    required this.specialties,
    required this.verified,
    required this.nextSlot,
    required this.gradientColors,
    required this.filterTag,
    required this.phone,
    required this.telegram,
    required this.instagram,
    required this.experienceYears,
    this.photoUrl,
  });
}
