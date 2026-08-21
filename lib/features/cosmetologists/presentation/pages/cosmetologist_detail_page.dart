import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/models/cosmetolog.dart';
import 'package:real_beauty_ai/features/cosmetologists/presentation/pages/cosmetologist_page.dart';
import 'package:real_beauty_ai/core/l10n/l10n_extension.dart';

class KosmetologDetailScreen extends StatefulWidget {
  final Cosmetolog cosmetolog;
  const KosmetologDetailScreen({super.key, required this.cosmetolog});

  @override
  State<KosmetologDetailScreen> createState() => _KosmetologDetailScreenState();
}

class _KosmetologDetailScreenState extends State<KosmetologDetailScreen> {
  bool _scrolled = false;
  late final ScrollController _scrollCtrl;

  Cosmetolog get c => widget.cosmetolog;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(() {
      final nowScrolled = _scrollCtrl.offset > 12;
      if (nowScrolled != _scrolled) setState(() => _scrolled = nowScrolled);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _launch(Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) _showLaunchError();
    } catch (_) {
      if (mounted) _showLaunchError();
    }
  }

  void _showLaunchError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.cosmoCallFailed,
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openPhone() {
    HapticFeedback.mediumImpact();
    if (c.phone.trim().isEmpty) return;
    _launch(Uri.parse('tel:${c.phone.replaceAll(' ', '')}'));
  }

  void _openTelegram() {
    HapticFeedback.mediumImpact();
    if (c.telegram.trim().isEmpty) return;
    _launch(Uri.parse('https://t.me/${c.telegram.replaceFirst('@', '')}'));
  }

  void _openInstagram() {
    HapticFeedback.mediumImpact();
    if (c.instagram.trim().isEmpty) return;
    _launch(Uri.parse('https://instagram.com/${c.instagram.replaceFirst('@', '')}'));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: _scrollCtrl,
            slivers: [

              // ── App bar ─────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                elevation: _scrolled ? 0.5 : 0,
                backgroundColor: _scrolled ? Colors.white : Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                automaticallyImplyLeading: false,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _scrolled
                          ? AppColors.background
                          : Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left, color: AppColors.text, size: 24),
                  ),
                ),
              ),

              // ── Header: avatar · ism · unvon · rating ───────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFE4DCF5), Color(0xFFF6F3FB), Colors.white],
                      stops: [0.0, 0.62, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CosmetologAvatar(
                          name: c.name,
                          gradientColors: c.gradientColors,
                          photoUrl: c.photoUrl,
                          size: 112,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              c.name,
                              style: GoogleFonts.nunito(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (c.verified) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 12),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.title,
                        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stat tiles: Tajriba · Manzil ───────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Tajriba',
                          value: context.l10n.cosmoYears(c.experienceYears),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.location_on_outlined,
                          label: 'Manzil',
                          value: c.city,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Telefon (tappable InfoRow) ──────────────────────────
              if (c.phone.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('TELEFON'),
                        const SizedBox(height: 10),
                        _PhoneRow(phone: c.phone, onTap: _openPhone),
                      ],
                    ),
                  ),
                ),

              // ── Haqida ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('HAQIDA'),
                      const SizedBox(height: 10),
                      Text(
                        c.bio,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: const Color(0xFF5A5470),
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Mutaxassisliklar ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, bottomPad + 104),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('MUTAXASSISLIKLAR'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: c.specialties.map((s) => Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: Text(
                              s,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom bar: Telegram (outlined) · Instagram (filled) ─────
          if (c.telegram.isNotEmpty || c.instagram.isNotEmpty)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.97),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (c.telegram.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openTelegram,
                      icon: SvgPicture.asset(
                        'assets/icons/telegram.svg',
                        width: 18,
                        height: 18,
                      ),
                      label: Text(
                        'Telegram',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2AABEE),
                        side: const BorderSide(color: Color(0xFF2AABEE), width: 1.5),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  if (c.telegram.isNotEmpty && c.instagram.isNotEmpty)
                    const SizedBox(width: 12),
                  if (c.instagram.isNotEmpty)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openInstagram,
                      icon: SvgPicture.asset(
                        'assets/icons/instagram.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(
                        'Instagram',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE1306C),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PhoneRow extends StatefulWidget {
  final String phone;
  final VoidCallback onTap;
  const _PhoneRow({required this.phone, required this.onTap});

  @override
  State<_PhoneRow> createState() => _PhoneRowState();
}

class _PhoneRowState extends State<_PhoneRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.phone,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.muted,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted,
                  ),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
