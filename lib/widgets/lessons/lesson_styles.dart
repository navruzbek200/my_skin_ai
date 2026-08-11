import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class LessonStyles {
  /// An item's accent hue, darkened until it can be read as text sitting on
  /// its own 12% tint.
  ///
  /// The chips take their colour from the lesson or article they belong to,
  /// and the raw hues are picked to look good as a 4px bar, not as 11px text:
  /// `#FF6B6B` and `#FF9F43` at full strength on a near-white chip are around
  /// 2.5:1. Capping lightness at 0.32 pulls the worst case in the data
  /// (`#FF6B6B`, lightness 0.71) to roughly 7:1 and leaves the hue intact, so
  /// the card still reads as "the red one" without the label going pale.
  static Color readableAccent(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return hsl.withLightness(math.min(hsl.lightness, 0.32)).toColor();
  }

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

  // There is deliberately no entrance animation for list cards here.
  //
  // Cards in the Darslar lists live inside SliverChildBuilderDelegate, which
  // builds a child when it nears the viewport and throws it away once it is
  // far enough past. An index-staggered `.animate(delay: index * 40ms)` on
  // such a child does two visibly wrong things: a card built at index 8 sits
  // at opacity 0 for a third of a second before it fades in, so content
  // arrives late while the finger is still moving; and every time a card is
  // scrolled back to, it is a brand-new element, so the whole fade-and-slide
  // replays from scratch. Scrolling up and down the same list made the same
  // cards blink in over and over. Lists show their content immediately.
}
