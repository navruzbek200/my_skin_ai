import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/features/cosmetologists/presentation/bloc/cosmetologists_cubit.dart';
import 'package:real_beauty_ai/models/cosmetolog.dart';
import 'package:real_beauty_ai/widgets/chip_button.dart';
import 'package:go_router/go_router.dart';

class KonnikmaScreen extends StatelessWidget {
  const KonnikmaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CosmetologistsCubit()..load(),
      child: const _KonnikmaBody(),
    );
  }
}

class _KonnikmaBody extends StatefulWidget {
  const _KonnikmaBody();

  @override
  State<_KonnikmaBody> createState() => _KonnikmaBodyState();
}

class _KonnikmaBodyState extends State<_KonnikmaBody> {
  String _search = '';
  String _filter = 'Barchasi';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static const _filters = ['Barchasi', 'Facialist', 'Dermatolog', 'Estetik', 'Injeksion'];

  List<Cosmetolog> _filtered(List<Cosmetolog> all) {
    return all.where((c) {
      final matchSearch = _search.isEmpty ||
          c.name.toLowerCase().contains(_search.toLowerCase()) ||
          c.title.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'Barchasi' || c.filterTag == _filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CosmetologistsCubit, CosmetologistsState>(
        builder: (context, state) {
          return NotificationListener<ScrollStartNotification>(
            onNotification: (_) {
              FocusScope.of(context).unfocus();
              return false;
            },
            child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kosmetologlar',
                              style: GoogleFonts.nunito(
                                fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                context.push('/account');
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFECE8F5)),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: Color(0xFF9490B0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _search = v),
                            style: GoogleFonts.nunito(fontSize: 14, color: AppColors.text),
                            decoration: InputDecoration(
                              hintText: 'Kosmetolog qidirish...',
                              hintStyle: GoogleFonts.nunito(color: AppColors.muted, fontSize: 14),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
                              suffixIcon: _search.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        _searchCtrl.clear();
                                        setState(() => _search = '');
                                      },
                                      child: const Icon(Icons.close_rounded, color: AppColors.muted, size: 18),
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _filters
                                .map((f) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChipButton(
                                        label: f,
                                        selected: f == _filter,
                                        onTap: () => setState(() => _filter = f),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              if (state is CosmetologistsLoading)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, _) => Container(
                        height: 88,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEAF8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(
                            duration: const Duration(milliseconds: 1200),
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                      childCount: 5,
                    ),
                  ),
                )
              else if (state is CosmetologistsError)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.muted),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: GoogleFonts.nunito(fontSize: 15, color: AppColors.muted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => context.read<CosmetologistsCubit>().load(),
                            child: Text(
                              'Qayta urinish',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (state is CosmetologistsLoaded) ...[
                Builder(builder: (context) {
                  final filtered = _filtered(state.items);
                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                        child: Column(
                          children: [
                            Icon(
                              _search.isNotEmpty
                                  ? Icons.search_off_rounded
                                  : Icons.filter_list_off_rounded,
                              size: 52,
                              color: AppColors.muted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _search.isNotEmpty
                                  ? '"$_search" bo\'yicha hech narsa topilmadi'
                                  : '$_filter bo\'yicha kosmetolog topilmadi',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Boshqa kalit so'z yoki filtr sinab ko'ring",
                              style: GoogleFonts.nunito(fontSize: 13, color: AppColors.muted),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _CosmetologCard(cosmetolog: filtered[i], index: i),
                        childCount: filtered.length,
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
          );
        },
      ),
    );
  }
}

class _CosmetologCard extends StatefulWidget {
  final Cosmetolog cosmetolog;
  final int index;
  const _CosmetologCard({required this.cosmetolog, required this.index});

  @override
  State<_CosmetologCard> createState() => _CosmetologCardState();
}

class _CosmetologCardState extends State<_CosmetologCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cosmetolog;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        context.push('/cosmetolog-detail', extra: c);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CosmetologAvatar(
                  name: c.name,
                  gradientColors: c.gradientColors,
                  photoUrl: c.photoUrl,
                  size: 60,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              c.name,
                              style: GoogleFonts.nunito(
                                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (c.verified) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 16, height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3B82F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 10),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.title,
                        style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium_outlined,
                              size: 13, color: AppColors.muted),
                          const SizedBox(width: 2),
                          Text(
                            '${c.experienceYears} yillik tajriba',
                            style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.muted),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              c.distance.isEmpty ? c.city : '${c.city} · ${c.distance}',
                              style: GoogleFonts.nunito(fontSize: 12, color: AppColors.muted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 60))
        .fadeIn()
        .slideX(begin: 0.05);
  }
}

class CosmetologAvatar extends StatefulWidget {
  final String name;
  final List<Color> gradientColors;
  final String? photoUrl;
  final double size;

  const CosmetologAvatar({
    super.key,
    required this.name,
    required this.gradientColors,
    this.photoUrl,
    this.size = 60,
  });

  @override
  State<CosmetologAvatar> createState() => _CosmetologAvatarState();
}

class _CosmetologAvatarState extends State<CosmetologAvatar> {
  OverlayEntry? _previewEntry;

  String get _initials {
    final parts = widget.name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'RB';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Alignment get _alignment {
    if (widget.photoUrl?.contains('nazokat_ismoilova') ?? false) {
      return const Alignment(0, -0.6);
    }
    if (widget.photoUrl?.contains('muhayyo_umarova') ?? false) {
      return const Alignment(0, 0.3);
    }
    return Alignment.center;
  }

  double get _scale {
    if (widget.photoUrl?.contains('muhayyo_umarova') ?? false) {
      return 2.6;
    }
    return 1.0;
  }

  void _showPreview() {
    if (widget.photoUrl == null || _previewEntry != null) return;
    HapticFeedback.mediumImpact();
    _previewEntry = OverlayEntry(
      builder: (_) => _AvatarPreviewOverlay(
        photoUrl: widget.photoUrl!,
        gradientColors: widget.gradientColors,
        initials: _initials,
        alignment: _alignment,
        scale: _scale,
      ),
    );
    Overlay.of(context).insert(_previewEntry!);
  }

  void _hidePreview() {
    _previewEntry?.remove();
    _previewEntry = null;
  }

  @override
  void dispose() {
    _previewEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _showPreview(),
      onLongPressEnd: (_) => _hidePreview(),
      onLongPressCancel: _hidePreview,
      child: _buildAvatar(),
    );
  }

  Widget _buildAvatar() {
    final url = widget.photoUrl;
    if (url != null && url.startsWith('assets/')) {
      return ClipOval(
        child: Transform.scale(
          scale: _scale,
          alignment: _alignment,
          child: Image.asset(
            url,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            alignment: _alignment,
            errorBuilder: (_, _, _) => _gradient(),
          ),
        ),
      );
    }
    if (url != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          alignment: _alignment,
          placeholder: (_, _) => _gradient(),
          errorWidget: (_, _, _) => _gradient(),
        ),
      );
    }
    return _gradient();
  }

  Widget _gradient() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: widget.size * 0.37,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _AvatarPreviewOverlay extends StatefulWidget {
  final String photoUrl;
  final List<Color> gradientColors;
  final String initials;
  final Alignment alignment;
  final double scale;

  const _AvatarPreviewOverlay({
    required this.photoUrl,
    required this.gradientColors,
    required this.initials,
    required this.alignment,
    required this.scale,
  });

  @override
  State<_AvatarPreviewOverlay> createState() => _AvatarPreviewOverlayState();
}

class _AvatarPreviewOverlayState extends State<_AvatarPreviewOverlay> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final previewSize = screenWidth * 0.75;
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          color: Colors.black.withValues(alpha: 0.55),
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: AnimatedScale(
              scale: _visible ? 1 : 0.85,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Container(
                width: previewSize,
                height: previewSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Transform.scale(
                    scale: widget.scale,
                    alignment: widget.alignment,
                    child: widget.photoUrl.startsWith('assets/')
                      ? Image.asset(
                          widget.photoUrl,
                          width: previewSize,
                          height: previewSize,
                          fit: BoxFit.cover,
                          alignment: widget.alignment,
                          errorBuilder: (_, _, _) => _fallback(previewSize),
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.photoUrl,
                          width: previewSize,
                          height: previewSize,
                          alignment: widget.alignment,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => _fallback(previewSize),
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback(double previewSize) {
    return Container(
      width: previewSize,
      height: previewSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          widget.initials,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: previewSize * 0.25,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
