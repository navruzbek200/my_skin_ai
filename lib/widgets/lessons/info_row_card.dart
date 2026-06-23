import 'package:flutter/material.dart';
import 'lesson_styles.dart';

class InfoRowCard extends StatelessWidget {
  final Color accentColor;
  final Widget? leading;
  final Widget content;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsets margin;
  final double radius;
  final bool showAccentBar;

  const InfoRowCard({
    super.key,
    required this.accentColor,
    required this.content,
    this.leading,
    this.trailing,
    this.onTap,
    this.showAccentBar = true,
    this.margin = const EdgeInsets.only(bottom: 10),
    this.radius = LessonStyles.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: LessonStyles.cardShadow,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showAccentBar)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(radius),
                    ),
                  ),
                ),
              // ignore: use_null_aware_elements
              if (leading != null) leading!,
              Expanded(child: content),
              // ignore: use_null_aware_elements
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
