import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:go_router/go_router.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildGradientBg(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skanerla',
                    style: GoogleFonts.nunito(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF7060AA),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  Text(
                    'Kamera orqali yuzni tahlil qiling',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 36),

                  GestureDetector(
                    onTap: () => context.push('/quiz'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              const Color(0xFF9B7DD4).withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7060AA).withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF9B7DD4), Color(0xFF7060AA)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.face_retouching_natural_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Yuzni tahlil qilish',
                                  style: GoogleFonts.nunito(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2D2050),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kamera va savol-javob orqali teri tipingizni aniqlang',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7060AA).withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: Color(0xFF7060AA),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBg() {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFCFC8E8),
            Color(0xFFE4D8F0),
            Color(0xFFF5EEF8),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.28, 0.55, 1.0],
        ),
      ),
    );
  }
}
