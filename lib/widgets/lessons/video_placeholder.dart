import 'package:flutter/material.dart';

class VideoPlaceholder extends StatelessWidget {
  final Color color;
  final IconData icon;
  const VideoPlaceholder({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color.withValues(alpha: 0.08),
      child: Center(
        child: Icon(icon, size: 40, color: color.withValues(alpha: 0.4)),
      ),
    );
  }
}
