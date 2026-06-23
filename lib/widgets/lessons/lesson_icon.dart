import 'package:flutter/material.dart';

class LessonIcon extends StatelessWidget {
  final Color color;
  final String id;

  const LessonIcon({super.key, required this.color, required this.id});

  static const Map<String, IconData> _icons = {
    'niacinamide': Icons.hexagon_outlined,
    'spf': Icons.wb_sunny_outlined,
    'arbutin': Icons.eco_outlined,
    'retinol': Icons.autorenew,
    'hyaluronic': Icons.water_drop_outlined,
    'peptides': Icons.link,
  };

  @override
  Widget build(BuildContext context) {
    return Icon(_icons[id] ?? Icons.science_outlined, color: color, size: 26);
  }
}
