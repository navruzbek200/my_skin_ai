import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:real_beauty_ai/core/constants/api_constants.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/services/local_store.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  /// Email address of the signed-in account (email/password or Google).
  String get _contactLabel => FirebaseAuth.instance.currentUser?.email ?? '';

  /// Google accounts carry a display name; email sign-ups don't collect one,
  /// so those fall back to the first letter of the email.
  String get _initials {
    final name = FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    if (name.isNotEmpty) return name[0].toUpperCase();
    if (_contactLabel.isEmpty) return '?';
    return _contactLabel[0].toUpperCase();
  }

  // ── Logout ──────────────────────────────────────────────────

  void _confirmLogout() {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Chiqasizmi?',
        body: 'Hisobdan chiqishni tasdiqlaysizmi?',
        confirmLabel: 'Chiqish',
        confirmColor: AppColors.primary,
        onConfirm: () async {
          Navigator.of(context).pop();
          await context.read<AuthCubit>().logout();
          if (!mounted) return;
          context.go('/');
        },
      ),
    );
  }

  // ── Delete account ───────────────────────────────────────────

  void _confirmDelete() {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: "Akkauntni o'chirish",
        body: "Akkaunt butunlay o'chiriladi. Davom etasizmi?",
        confirmLabel: "O'chirish",
        confirmColor: Colors.red.shade500,
        onConfirm: () async {
          Navigator.of(context).pop();
          // Always re-authenticate first: deletion is destructive and the
          // server callable removes the Auth record *and* the Firestore docs,
          // so it must be a deliberate, freshly-confirmed action.
          _showReAuthSheet();
        },
      ),
    );
  }

  Future<void> _clearAndExit() async {
    await LocalStore.instance.clearAllUserData();
    await LocalStore.instance.setLoggedOut();
    AppLogger.info('Account deleted — local data cleared');
    if (!mounted) return;
    context.go('/');
  }

  void _showReAuthSheet() {
    final cubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final isGoogleUser = cubit.isGoogleOnlyUser;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _ReAuthSheet(
          isGoogleUser: isGoogleUser,
          messenger: messenger,
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profile = LocalStore.instance.getSkinProfile();
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthDeleted) _clearAndExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: top + 8)),

            // ── Nav bar ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'Hisob',
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFEAE8F5),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 15,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Avatar ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9B7DD4), Color(0xFF5040A0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7060AA).withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: GoogleFonts.nunito(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_contactLabel.isNotEmpty)
                      Text(
                        _contactLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      )
                    else
                      Text(
                        'My Skin AI foydalanuvchisi',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Teri profili ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionCard(
                  label: 'Teri profili',
                  child: profile != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF9B7DD4), Color(0xFF7060AA)],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    profile.skinType,
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile.baseRecommendation,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: AppColors.muted,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ActionRow(
                              icon: Icons.refresh_rounded,
                              label: "Tahlilni qayta o'tkazish",
                              onTap: () => context.push('/quiz'),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hali tahlil qilinmagan',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _ActionRow(
                              icon: Icons.face_retouching_natural_rounded,
                              label: 'Tahlilni boshlash',
                              onTap: () => context.push('/quiz'),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Sozlamalar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionCard(
                  label: 'Sozlamalar',
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Maxfiylik siyosati',
                        onTap: () => launchUrl(
                          Uri.parse(privacyPolicyUrl),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(height: 1, color: Color(0xFFF0ECF8)),
                      ),
                      _ActionRow(
                        icon: Icons.logout_rounded,
                        label: 'Chiqish',
                        onTap: _confirmLogout,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Divider(height: 1, color: Color(0xFFF0ECF8)),
                      ),
                      _ActionRow(
                        icon: Icons.delete_outline_rounded,
                        label: "Akkauntni o'chirish",
                        color: Colors.red.shade400,
                        onTap: _confirmDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: bottom + 40)),
          ],
        ),
      ),
    );
  }
}

// ── Re-auth sheet ─────────────────────────────────────────────

class _ReAuthSheet extends StatefulWidget {
  final bool isGoogleUser;
  final ScaffoldMessengerState messenger;

  const _ReAuthSheet({
    required this.isGoogleUser,
    required this.messenger,
  });

  @override
  State<_ReAuthSheet> createState() => _ReAuthSheetState();
}

class _ReAuthSheetState extends State<_ReAuthSheet> {
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submitGoogle() {
    setState(() {
      _loading = true;
      _error = null;
    });
    context.read<AuthCubit>().reauthenticateWithGoogleAndDelete();
  }

  void _submitPassword() {
    final password = _passwordCtrl.text;
    if (password.isEmpty) {
      setState(() => _error = "Parolni kiriting");
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    context.read<AuthCubit>().reauthenticateAndDelete(password);
  }

  void _onPrimaryTap() {
    if (widget.isGoogleUser) {
      _submitGoogle();
    } else {
      _submitPassword();
    }
  }

  String get _primaryLabel {
    if (widget.isGoogleUser) return "Google bilan tasdiqlab o'chirish";
    return "Tasdiqlab o'chirish";
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          setState(() {
            _loading = false;
            _error = state.message;
          });
        } else if (state is AuthInitial) {
          // Google picker was dismissed — stop the spinner, stay on the sheet.
          setState(() => _loading = false);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0DBF0),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kimligingizni tasdiqlang',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isGoogleUser
                  ? "Akkauntni o'chirish uchun Google hisobingiz orqali tasdiqlang."
                  : "Akkauntni o'chirish uchun parolingizni kiriting.",
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            if (!widget.isGoogleUser) ...[
              _AuthField(
                controller: _passwordCtrl,
                hint: 'Parol',
                obscureText: true,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.red.shade500,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _onPrimaryTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  disabledBackgroundColor: Colors.red.shade200,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isGoogleUser) ...[
                            SvgPicture.asset(
                              'assets/icons/google.svg',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            _primaryLabel,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirm dialog ─────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;
  final Future<void> Function() onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          color: AppColors.text,
          fontSize: 17,
        ),
      ),
      content: Text(
        body,
        style: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.muted,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Bekor qilish',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmLabel,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: confirmColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section card ──────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _SectionCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

// ── Action row ────────────────────────────────────────────────

class _ActionRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppColors.text;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _pressed ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: c),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: c,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: c.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Auth field ────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.nunito(fontSize: 14, color: AppColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.muted),
        filled: true,
        fillColor: const Color(0xFFF8F7FC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAE8F5), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEAE8F5), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
