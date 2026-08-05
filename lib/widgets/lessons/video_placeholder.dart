import 'package:flutter/material.dart';

class VideoPlaceholder extends StatelessWidget {
  final Color color;
  final IconData icon;
  const VideoPlaceholder({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF5F3FA),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              color.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
