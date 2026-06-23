import 'package:flutter/material.dart';

abstract final class LessonStyles {
  // Radii
  static const double cardRadius = 16.0;
  static const double yogaCardRadius = 20.0;
  static const double yogaSectionRadius = 20.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Animations
  static const Duration enterDuration = Duration(milliseconds: 280);
  static const Duration enterSlow = Duration(milliseconds: 350);
  static Duration stagger(int index) => Duration(milliseconds: index * 70);
}
