import 'package:flutter/material.dart';

import 'package:real_beauty_ai/core/l10n/localized_text.dart';

class YogaExercise {
  final LocalizedText name;
  final LocalizedText duration;
  final LocalizedText target;
  final LocalizedText description;
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

/// Shared by every clip. Held here so the wording cannot drift between the
/// silent set and the narrated one.
const _oneMinute = LocalizedText('1 daqiqa', '1 минута', '1 minute');
const _twoMinutes = LocalizedText('2 daqiqa', '2 минуты', '2 minutes');
const _facialSkin = LocalizedText('Yuz terisi', 'Кожа лица', 'Facial skin');
const _underEye = LocalizedText("Ko'z osti", 'Под глазами', 'Under-eye');

final List<YogaExercise> yogaExercises = [
  YogaExercise(
    name: const LocalizedText(
        "Jag' chizig'i", 'Линия челюсти', 'Jawline'),
    duration: _oneMinute,
    target: const LocalizedText(
        "Jag' & Iyak", 'Челюсть и подбородок', 'Jaw and chin'),
    description: const LocalizedText(
      "Ikkinchi iyakni kamaytiradi, jag' chizig'ini keskin qiladi va yuz shaklini aniqlashtiradi.",
      'Уменьшает второй подбородок, делает линию челюсти чётче и подчёркивает форму лица.',
      'Reduces a double chin, sharpens the jawline and defines the shape of the face.',
    ),
    color: const Color(0xFF9B7DD4),
    icon: Icons.face_retouching_natural_outlined,
    videoPath: 'assets/videos/jawline1.mp4',
  ),
  YogaExercise(
    name: const LocalizedText(
        "Yuz ko'tarish", 'Лифтинг лица', 'Face lift'),
    duration: _oneMinute,
    target: _facialSkin,
    description: const LocalizedText(
      "Teri tortilishini oshiradi, yoshlash effekti beradi va bo'shashgan teriga qarshi kurashadi.",
      'Повышает упругость кожи, даёт эффект омоложения и работает против провисания.',
      'Improves firmness, gives a rejuvenating effect and works against sagging.',
    ),
    color: const Color(0xFF5B8DD9),
    icon: Icons.auto_awesome_outlined,
    videoPath: 'assets/videos/facelift2.mp4',
  ),
  YogaExercise(
    name: const LocalizedText(
        'Burun ingichkalashtirish', 'Сужение носа', 'Nose slimming'),
    duration: _oneMinute,
    target: const LocalizedText(
        'Burun atrofi', 'Область носа', 'Around the nose'),
    description: const LocalizedText(
      "Burun atrofidagi mushaklarni mustahkamlaydi va burun ko'rinishini optimallashtiradi.",
      'Укрепляет мышцы вокруг носа и делает его форму более гармоничной.',
      'Strengthens the muscles around the nose and refines its appearance.',
    ),
    color: const Color(0xFFEC4899),
    icon: Icons.self_improvement,
    videoPath: 'assets/videos/slimnose3.mp4',
  ),
  YogaExercise(
    name: const LocalizedText(
        "Yonoq ko'tarish", 'Подъём скул', 'Cheek lift'),
    duration: _oneMinute,
    target: const LocalizedText('Yonoq suyagi', 'Скулы', 'Cheekbones'),
    description: const LocalizedText(
      "Yonoq suyaklarini ko'taradi, yuzni hajmli ko'rsatadi va kulgi chiziqlarini kamaytiradi.",
      'Приподнимает скулы, придаёт лицу объём и смягчает носогубные складки.',
      'Lifts the cheekbones, adds volume to the face and softens smile lines.',
    ),
    color: const Color(0xFF22C55E),
    icon: Icons.sentiment_very_satisfied_outlined,
    videoPath: 'assets/videos/cheeklift4.mp4',
  ),
  YogaExercise(
    name: const LocalizedText(
        "Ko'z atrofi", 'Вокруг глаз', 'Around the eyes'),
    duration: _oneMinute,
    target: const LocalizedText(
        "Ko'z burchagi", 'Уголки глаз', 'Corners of the eyes'),
    description: const LocalizedText(
      "Ko'z burchagidagi ajinlarni tekislaydi va ko'z atrofi terisi elastikligini oshiradi.",
      'Разглаживает морщинки в уголках глаз и повышает упругость кожи вокруг них.',
      'Smooths crow\'s feet and improves the elasticity of the skin around the eyes.',
    ),
    color: const Color(0xFFFF8A35),
    icon: Icons.remove_red_eye_outlined,
    videoPath: 'assets/videos/crowsfeet5.mp4',
  ),
  YogaExercise(
    name: _underEye,
    duration: _oneMinute,
    target: _underEye,
    description: const LocalizedText(
      "Ko'z osti shishini kamaytiradi, to'q doiralarga qarshi ta'sir qiladi va terisini yoritadi.",
      'Уменьшает отёки под глазами, работает против тёмных кругов и осветляет кожу.',
      'Reduces puffiness under the eyes, works against dark circles and brightens the skin.',
    ),
    color: const Color(0xFF8B5CF6),
    icon: Icons.spa_outlined,
    videoPath: 'assets/videos/eyebags6.mp4',
  ),
];

final List<YogaExercise> yogaVoiceExercises = [
  YogaExercise(
    name: const LocalizedText(
        'Umumiy yuz yoga', 'Общая фейс-йога', 'Full face yoga'),
    duration: _oneMinute,
    target: const LocalizedText('Butun yuz', 'Всё лицо', 'The whole face'),
    description: const LocalizedText(
      'Butun yuz mushaklarini isitadi, qon aylanishini yaxshilaydi va mashqlarga tayyorlaydi.',
      'Разогревает мышцы всего лица, улучшает кровообращение и готовит к упражнениям.',
      'Warms up every facial muscle, improves circulation and prepares you for the exercises.',
    ),
    color: const Color(0xFFF59E0B),
    icon: Icons.face_outlined,
    videoPath: 'assets/videos/yoga_voice/1.mp4',
    clipHeightFactor: 1.0,
  ),
  YogaExercise(
    // The clip itself is titled in English; renaming it in the list would make
    // the card and the video disagree.
    name: const LocalizedText.same('Lifting effect'),
    duration: _oneMinute,
    target: _facialSkin,
    description: const LocalizedText(
      "Yuz mushaklarini ko'taradi, teri tonusini oshiradi va yoshlash effektini beradi.",
      'Приподнимает мышцы лица, повышает тонус кожи и даёт эффект омоложения.',
      'Lifts the facial muscles, improves skin tone and gives a rejuvenating effect.',
    ),
    color: const Color(0xFFEF4444),
    icon: Icons.sentiment_satisfied_outlined,
    videoPath: 'assets/videos/yoga_voice/2.mp4',
    clipHeightFactor: 1.0,
  ),
  YogaExercise(
    name: _underEye,
    duration: _oneMinute,
    target: _underEye,
    description: const LocalizedText(
      "Ko'z osti shishini va to'q doiralarini kamaytiradi, terisini yoritadi.",
      'Уменьшает отёки и тёмные круги под глазами, осветляет кожу.',
      'Reduces puffiness and dark circles under the eyes and brightens the skin.',
    ),
    color: const Color(0xFF14B8A6),
    icon: Icons.remove_red_eye_outlined,
    videoPath: 'assets/videos/yoga_voice/3.mp4',
    clipHeightFactor: 0.88,
    clipAlignmentY: 1.0,
  ),
  YogaExercise(
    name: const LocalizedText.same('V-line'),
    duration: _twoMinutes,
    target: const LocalizedText(
        'Baqbaqa & Iyak', 'Шея и подбородок', 'Neck and chin'),
    description: const LocalizedText(
      "Ikkinchi iyakni kamaytiradi, baqbaqa mushaklarini mustahkamlaydi va jag' chizig'ini aniqlashtiradi.",
      'Уменьшает второй подбородок, укрепляет мышцы шеи и подчёркивает линию челюсти.',
      'Reduces a double chin, strengthens the neck muscles and defines the jawline.',
    ),
    color: const Color(0xFF06B6D4),
    icon: Icons.auto_awesome_outlined,
    videoPath: 'assets/videos/yoga_voice/4.mp4',
    clipHeightFactor: 1.0,
  ),
];
