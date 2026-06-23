import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/features/home/presentation/pages/bugun_page.dart';
import 'package:real_beauty_ai/features/products/presentation/pages/products_page.dart';
import 'package:real_beauty_ai/features/scanner/presentation/pages/scanner_page.dart';
import 'package:real_beauty_ai/features/lessons/presentation/pages/lessons_page.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/features/cosmetologists/presentation/pages/cosmetologist_page.dart';
import 'package:real_beauty_ai/services/local_store.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Show once per install, for every user, regardless of profile state.
    // Mark seen immediately so dismissing the dialog never re-shows it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        if (!LocalStore.instance.hasSkinProfile) {
          _showAnalysisModal();
        }
      });
    });
  }

  void _showAnalysisModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierDismissible: true,
      builder: (_) => _SkinAnalysisModal(
        onStart: () {
          Navigator.pop(context);
          context.push('/quiz');
        },
      ),
    );
  }

  List<Widget> get _screens => [
    const BugunScreen(),
    const ProductsScreen(),
    const ScannerScreen(),
    const LessonsScreen(),
    const KonnikmaScreen(),
  ];

  // Uzbekistan time UTC+5
  bool get _isDaytime {
    final uzt = DateTime.now().toUtc().add(const Duration(hours: 5));
    return uzt.hour >= 6 && uzt.hour < 18;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final bugunSvg = _isDaytime ? 'assets/icons/sun.svg' : 'assets/icons/moon.svg';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(12, 8, 12, bottom > 0 ? bottom : 14),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFFECE8F5), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5040A0).withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFF5040A0).withValues(alpha: 0.05),
                blurRadius: 40,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                svgPath: bugunSvg,
                label: 'Bugun',
                active: _currentIndex == 0,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = 0);
                },
              ),
              _NavItem(
                imagePath: 'assets/icons/cosmetics.png',
                label: 'Mahsulot',
                active: _currentIndex == 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = 1);
                },
              ),
              // Center scan button
              Semantics(
                label: 'Skan',
                button: true,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _currentIndex = 2);
                  },
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B72CC), Color(0xFF5040A0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5040A0).withValues(alpha: 0.38),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.crop_free_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Skan',
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _currentIndex == 2 ? AppColors.primary : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _NavItem(
                imagePath: 'assets/icons/ideas.png',
                label: 'Darslar',
                active: _currentIndex == 3,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = 3);
                },
              ),
              _NavItem(
                imagePath: 'assets/icons/customer.png',
                label: "Ko'nikma",
                active: _currentIndex == 4,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = 4);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skin analysis modal ──────────────────────────────────────

class _SkinAnalysisModal extends StatefulWidget {
  final VoidCallback onStart;
  const _SkinAnalysisModal({required this.onStart});

  @override
  State<_SkinAnalysisModal> createState() => _SkinAnalysisModalState();
}

class _SkinAnalysisModalState extends State<_SkinAnalysisModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scale = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutBack);
    _fade  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: AnimatedBuilder(
        animation: _enterCtrl,
        builder: (_, child) => FadeTransition(
          opacity: _fade,
          child: ScaleTransition(scale: _scale, child: child),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              Stack(
                children: [
                  Image.asset(
                    'assets/banner_skin.jpg',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.5),
                  ),
                  // X top-right
                  Positioned(
                    top: 12, right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Text + button
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Teringizni tahlil qiling',
                      style: GoogleFonts.nunito(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2050),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Teri tipingizni aniqlash uchun qisqa savolnomaga javob bering va shaxsiylashtirilgan parvarish rejasini oling.',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: const Color(0xFF9490B0),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: widget.onStart,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B72CC), Color(0xFF5040A0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5040A0).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Tahlilni boshlash',
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav item ─────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final String? svgPath;
  final String? imagePath;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    this.svgPath,
    this.imagePath,
    required this.label,
    required this.active,
    required this.onTap,
  });

  Widget _buildIcon() {
    final colorFilter = ColorFilter.mode(
      active ? AppColors.primary : AppColors.muted,
      BlendMode.srcIn,
    );
    if (svgPath != null) {
      return SvgPicture.asset(svgPath!, width: 22, height: 22, colorFilter: colorFilter);
    }
    return ColorFiltered(
      colorFilter: colorFilter,
      child: Image.asset(imagePath!, width: 22, height: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF7060AA).withValues(alpha: 0.11)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildIcon(),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.primary : AppColors.muted,
              ),
              child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}
