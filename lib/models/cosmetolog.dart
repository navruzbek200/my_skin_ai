import 'package:flutter/material.dart';

class Cosmetolog {
  final String name;
  final String title;
  final double rating;
  final int reviewCount;
  final String distance;
  final String city;
  final String bio;
  final List<String> specialties;
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
