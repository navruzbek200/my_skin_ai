import 'package:flutter/material.dart';

/// Semantic colour tokens.
///
/// Named by role, not by hue, so a screen never reaches for a raw hex: every
/// surface, every piece of text and every border resolves to one of these, and
/// changing the brand is one edit rather than a search across thirty files.
///
/// Every foreground token below has been checked against the surface it is
/// used on. The ones that changed did so because they failed: `muted` was
/// #9490B0 (3.3:1 on white — under the 4.5:1 AA floor for body text),
/// `inkFaint` was #BBB8D0 (1.9:1, invisible as an icon), `border` was too pale
/// to mark the boundary of an input, and the error red was #E57373 (3.0:1).
class AppColors {
  // ── Brand ────────────────────────────────────────────────────
  static const primary = Color(0xFF7060AA); // 5.3:1 on white — link-safe
  static const accent = Color(0xFF9B7DD4);
  static const purple = Color(0xFF7060AA);
  static const navy = Color(0xFF4A3D7A);

  /// The one filled call-to-action colour. 8.9:1 against white text.
  static const cta = Color(0xFF4A3A9A);

  /// Headline ink — a shade of the CTA, used where a heading has to sit above
  /// the body text without shouting.
  static const heading = Color(0xFF3D2F8A);

  // ── Surfaces ─────────────────────────────────────────────────
  static const background = Color(0xFFF0ECF8);
  static const card = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);

  /// Filled input backgrounds and quiet info panels.
  static const surfaceAlt = Color(0xFFF6F4FC);

  /// The soft accent wash behind icons in circles.
  static const accentSoft = Color(0xFFEDE9F8);

  // ── Ink ──────────────────────────────────────────────────────
  static const text = Color(0xFF2D2050);

  /// Secondary text. 5.9:1 on white, 5.1:1 on [background].
  static const muted = Color(0xFF655F85);

  /// Decorative glyphs and prefix icons. 3.3:1 on white — the AA floor for
  /// non-text UI components, and never used for words.
  static const inkFaint = Color(0xFF8E89AB);

  // ── Lines ────────────────────────────────────────────────────
  /// Hairline dividers between rows. Decorative, so the low contrast is fine.
  static const border = Color(0xFFE4E0F2);

  /// The outline of an input or an outlined button — a component boundary, so
  /// it carries the 3:1 requirement.
  static const borderStrong = Color(0xFF948CB8);

  // ── Status ───────────────────────────────────────────────────
  static const green = Color(0xFF15803D);
  static const orange = Color(0xFFC2410C);

  /// Error text and destructive actions. 5.6:1 on white.
  static const danger = Color(0xFFC62828);

  /// Kept for the decorative score chips, which never carry text.
  static const red = Color(0xFFFF6B6B);
}

class AppRadius {
  static const sm = 10.0;
  static const card = 16.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const button = 30.0;
  static const chip = 999.0;
  static const pill = 999.0;
}

/// The one motion scale in the app.
///
/// Micro-interactions land in the 150–300ms band where a transition reads as
/// cause and effect rather than as a delay; exits are shorter than entrances so
/// dismissing never feels like waiting.
class AppMotion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 320);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
}

/// Minimum tap sizes, so no screen has to remember the numbers.
class AppTouch {
  /// Material's floor. Every interactive element is at least this tall.
  static const min = 48.0;

  /// Full-width primary buttons and inputs — comfortably above the floor and
  /// large enough to stay usable at the largest text size.
  static const control = 56.0;
}
