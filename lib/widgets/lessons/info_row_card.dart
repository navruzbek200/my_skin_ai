import 'package:flutter/material.dart';
import 'lesson_styles.dart';

class InfoRowCard extends StatefulWidget {
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
  State<InfoRowCard> createState() => _InfoRowCardState();
}

class _InfoRowCardState extends State<InfoRowCard> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.62 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: LessonStyles.cardBorderColor,
              width: 0.5,
            ),
            boxShadow: LessonStyles.cardShadow,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showAccentBar)
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(widget.radius),
                      ),
                    ),
                  ),
                if (widget.leading != null) widget.leading!,
                Expanded(child: widget.content),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
