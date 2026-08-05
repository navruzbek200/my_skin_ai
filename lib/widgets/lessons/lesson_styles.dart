import 'package:flutter/material.dart';

abstract final class LessonStyles {
  // Radii
  static const double cardRadius = 16.0;
  static const double yogaCardRadius = 20.0;
  static const double yogaSectionRadius = 20.0;

  // Shadows — two layers: key + ambient
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x14000000), // 8% key
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000), // 3% ambient lift
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  // Subtle border for cards on white bg
  static const Color cardBorderColor = Color(0x0F000000);

  // Animations — snappier stagger (40ms vs 70ms)
  static const Duration enterDuration = Duration(milliseconds: 260);
  static const Duration enterSlow = Duration(milliseconds: 350);
  static Duration stagger(int index) => Duration(milliseconds: index * 40);
}
