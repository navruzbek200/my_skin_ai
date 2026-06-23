import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppText {
  static TextStyle get h1 => GoogleFonts.nunito(
    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.text,
  );
  static TextStyle get h2 => GoogleFonts.nunito(
    fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text,
  );
  static TextStyle get h3 => GoogleFonts.nunito(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text,
  );
  static TextStyle get body => GoogleFonts.nunito(
    fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.text,
  );
  static TextStyle get bodyMuted => GoogleFonts.nunito(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.muted,
  );
  static TextStyle get label => GoogleFonts.nunito(
    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text,
  );
  static TextStyle get button => GoogleFonts.nunito(
    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white,
  );
  static TextStyle get caption => GoogleFonts.nunito(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted,
  );
}
