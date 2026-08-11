import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  /// Colour of the bar to the left of the title. Defaults to the brand
  /// primary; pass a section colour to tie the header to the cards under it.
  final Color color;

  /// How many items the section holds. Shown as a pill on the right so the
  /// list has a known length before it is scrolled — a plain heading gives no
  /// hint whether three cards follow or thirty.
  final int? count;

  const SectionHeader({
    super.key,
    required this.title,
    this.color = AppColors.primary,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
