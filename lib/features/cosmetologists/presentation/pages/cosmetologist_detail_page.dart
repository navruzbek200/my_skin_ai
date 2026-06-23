import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/models/cosmetolog.dart';
import 'package:real_beauty_ai/features/cosmetologists/presentation/pages/cosmetologist_page.dart';

class KosmetologDetailScreen extends StatefulWidget {
  final Cosmetolog cosmetolog;
  const KosmetologDetailScreen({super.key, required this.cosmetolog});

  @override
  State<KosmetologDetailScreen> createState() => _KosmetologDetailScreenState();
}

class _KosmetologDetailScreenState extends State<KosmetologDetailScreen> {
  bool _saved = false;
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

  void _openPhone() {
    HapticFeedback.mediumImpact();
    launchUrl(
      Uri.parse('tel:${c.phone.replaceAll(' ', '')}'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openTelegram() {
    HapticFeedback.mediumImpact();
    launchUrl(
      Uri.parse('https://t.me/${c.telegram.replaceFirst('@', '')}'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openInstagram() {
    HapticFeedback.mediumImpact();
    launchUrl(
      Uri.parse('https://instagram.com/${c.instagram.replaceFirst('@', '')}'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
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
                actions: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _saved = !_saved);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _scrolled
                            ? AppColors.background
                            : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          _saved ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          color: _saved ? AppColors.red : AppColors.text,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),

              // ── Header: avatar · ism · unvon · rating ───────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    children: [
                      CosmetologAvatar(
                        name: c.name,
                        gradientColors: c.gradientColors,
                        size: 112,
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CosmetologStarRating(value: c.rating, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${c.rating} · ${c.reviewCount} sharh',
                            style: GoogleFonts.nunito(fontSize: 13, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stat tiles: Tajriba · Sharhlar ─────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Tajriba',
                          value: '${c.experienceYears} yil',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.star_outline_rounded,
                          label: 'Sharhlar',
                          value: '${c.reviewCount} ta',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Telefon (tappable InfoRow) ──────────────────────────
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
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openTelegram,
                      icon: const Icon(Icons.send_rounded, size: 18),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _openInstagram,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
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
          Column(
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
                style: GoogleFonts.nunito(
                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
