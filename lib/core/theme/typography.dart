import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// One type scale for the whole app.
///
/// Sizes step 12 / 13 / 14 / 15 / 18 / 22 / 26 / 28 rather than drifting a
/// point at a time per screen, and body copy never drops below 14 — the floor
/// at which this typeface stays readable on a phone held at arm's length.
/// Line height is set explicitly on anything that wraps: Nunito's default
/// leading is tight, and a paragraph set solid is the single most common reason
/// a screen reads as cramped.
class AppText {
  static TextStyle get display => GoogleFonts.nunito(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.heading,
        height: 1.25,
      );
  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
        height: 1.2,
      );
  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.25,
      );
  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.3,
      );
  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
        height: 1.5,
      );
  static TextStyle get bodyMuted => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
        height: 1.55,
      );
  static TextStyle get bodySm => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
        height: 1.5,
      );
  static TextStyle get label => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );
  static TextStyle get labelSm => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      );
  static TextStyle get labelMuted => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        height: 1.45,
      );
  static TextStyle get button => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );
  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
        height: 1.4,
      );
}
