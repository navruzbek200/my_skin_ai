import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientBanner extends StatelessWidget {
  final List<Color> colors;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final double height;
  final String? imagePath;

  const GradientBanner({
    super.key,
    required this.colors,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.height = 140,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: image or gradient
            if (imagePath != null)
              Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                alignment: const Alignment(1.0, -0.75),
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

            // Gradient overlay for text readability
            if (imagePath != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.40),
                      Colors.black.withValues(alpha: 0.08),
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),

            // Text content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: imagePath != null
                                ? [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
