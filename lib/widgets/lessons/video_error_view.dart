import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoErrorView extends StatelessWidget {
  final Color color;
  final IconData icon;
  final VoidCallback onRetry;

  const VideoErrorView({
    super.key,
    required this.color,
    required this.icon,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: ColoredBox(
        color: color.withValues(alpha: 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Text(
              'qayta urinish',
              style: GoogleFonts.nunito(fontSize: 11, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
