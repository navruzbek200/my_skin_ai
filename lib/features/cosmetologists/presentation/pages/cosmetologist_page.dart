import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/features/cosmetologists/presentation/bloc/cosmetologists_cubit.dart';
import 'package:real_beauty_ai/models/cosmetolog.dart';
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
          return CustomScrollView(
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
                              "Ko'nikma",
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
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filters.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final f = _filters[i];
                              final sel = f == _filter;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _filter = f);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  decoration: BoxDecoration(
                                    color: sel ? AppColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 6,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      f,
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: sel ? Colors.white : AppColors.text,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              if (state is CosmetologistsLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      strokeWidth: 2.5,
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
                          CosmetologStarRating(value: c.rating),
                          const SizedBox(width: 6),
                          Text(
                            '${c.rating} (${c.reviewCount})',
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
                              '${c.city} · ${c.distance}',
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

class CosmetologAvatar extends StatelessWidget {
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

  String get _initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'RB';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => _gradient(),
          errorWidget: (_, _, _) => _gradient(),
        ),
      );
    }
    return _gradient();
  }

  Widget _gradient() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: size * 0.37,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class CosmetologStarRating extends StatelessWidget {
  final double value;
  final double size;
  const CosmetologStarRating({super.key, required this.value, this.size = 12});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value.floor();
        final half = !filled && i < value;
        return Icon(
          half ? Icons.star_half : filled ? Icons.star : Icons.star_outline,
          size: size,
          color: AppColors.accent,
        );
      }),
    );
  }
}
