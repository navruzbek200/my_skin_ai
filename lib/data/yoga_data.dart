import 'package:flutter/material.dart';

class YogaExercise {
  final String name;
  final String duration;
  final String target;
  final String description;
  final Color color;
  final IconData icon;
  final String videoPath;

  // Flutter-side crop fallback for uncropped source videos (720×1280 portrait).
  // Align+ClipRect shows only the middle band, hiding the burned-in title at
  // top and the before/after inset at bottom.
  // Set clipHeightFactor: 1.0 for any clip re-encoded with ffmpeg (no clipping needed).
  final double clipHeightFactor; // fraction of intrinsic video height to show
  final double clipAlignmentY;   // Align.alignment.y  (-1=top, 0=center, 1=bottom)

  const YogaExercise({
    required this.name,
    required this.duration,
    required this.target,
    required this.description,
    required this.color,
    required this.icon,
    required this.videoPath,
    this.clipHeightFactor = 0.52,
    this.clipAlignmentY = -0.35,
  });
}

final List<YogaExercise> yogaExercises = [
  YogaExercise(
    name: "Jag' chizig'i",
    duration: '1 daqiqa',
    target: "Jag' & Iyak",
    description:
        "Ikkinchi iyakni kamaytiradi, jag' chizig'ini keskin qiladi va yuz shaklini aniqlashtiradi.",
    color: const Color(0xFF9B7DD4),
    icon: Icons.face_retouching_natural_outlined,
    videoPath: 'assets/videos/jawline1.mp4',
  ),
  YogaExercise(
    name: "Yuz ko'tarish",
    duration: '1 daqiqa',
    target: 'Yuz terisi',
    description:
        "Teri tortilishini oshiradi, yoshlash effekti beradi va bo'shashgan teriga qarshi kurashadi.",
    color: const Color(0xFF5B8DD9),
    icon: Icons.auto_awesome_outlined,
    videoPath: 'assets/videos/facelift2.mp4',
  ),
  YogaExercise(
    name: 'Burun ingichkalashtirish',
    duration: '1 daqiqa',
    target: 'Burun atrofi',
    description:
        "Burun atrofidagi mushaklarni mustahkamlaydi va burun ko'rinishini optimallashtiradi.",
    color: const Color(0xFFEC4899),
    icon: Icons.self_improvement,
    videoPath: 'assets/videos/slimnose3.mp4',
  ),
  YogaExercise(
    name: "Yonoq ko'tarish",
    duration: '1 daqiqa',
    target: 'Yonoq suyagi',
    description:
        "Yonoq suyaklarini ko'taradi, yuzni hajmli ko'rsatadi va kulgi chiziqlarini kamaytiradi.",
    color: const Color(0xFF22C55E),
    icon: Icons.sentiment_very_satisfied_outlined,
    videoPath: 'assets/videos/cheeklift4.mp4',
  ),
  YogaExercise(
    name: "Ko'z atrofi",
    duration: '1 daqiqa',
    target: "Ko'z burchagi",
    description:
        "Ko'z burchagidagi ajinlarni tekislaydi va ko'z atrofi terisi elastikligini oshiradi.",
    color: const Color(0xFFFF8A35),
    icon: Icons.remove_red_eye_outlined,
    videoPath: 'assets/videos/crowsfeet5.mp4',
  ),
  YogaExercise(
    name: "Ko'z osti",
    duration: '1 daqiqa',
    target: "Ko'z osti",
    description:
        "Ko'z osti shishini kamaytiradi, to'q doiralarga qarshi ta'sir qiladi va terisini yoritadi.",
    color: const Color(0xFF8B5CF6),
    icon: Icons.spa_outlined,
    videoPath: 'assets/videos/eyebags6.mp4',
  ),
];
