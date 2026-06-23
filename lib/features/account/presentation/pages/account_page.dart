import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/services/local_store.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _actionLoading = false;

  String get _email =>
      FirebaseAuth.instance.currentUser?.email ?? '';

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
          await _tryDelete();
        },
      ),
    );
  }

  Future<void> _tryDelete() async {
    if (_actionLoading) return;
    setState(() => _actionLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      await _clearAndExit();
    } on FirebaseAuthException catch (e) {
      AppLogger.warning('deleteAccount failed', e.code);
      if (!mounted) return;
      setState(() => _actionLoading = false);
      if (e.code == 'requires-recent-login') {
        _showReAuthSheet();
      } else {
        _showError(_mapAuthError(e.code));
      }
    } catch (e, st) {
      AppLogger.error('deleteAccount unexpected', e, st);
      if (!mounted) return;
      setState(() => _actionLoading = false);
      _showError("Xato yuz berdi. Qaytadan urinib ko'ring");
    }
  }

  Future<void> _clearAndExit() async {
    await LocalStore.instance.clearSkinProfile();
    await LocalStore.instance.setLoggedOut();
    AppLogger.info('Account deleted — local data cleared');
    if (!mounted) return;
    context.go('/');
  }

  void _showReAuthSheet() {
    final cubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _ReAuthSheet(email: _email, messenger: messenger),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.red.shade500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _mapAuthError(String code) => switch (code) {
        'user-not-found' => "Foydalanuvchi topilmadi",
        'wrong-password' || 'invalid-credential' => "Parol noto'g'ri",
        'network-request-failed' => "Internet aloqasi yo'q",
        'too-many-requests' => "Ko'p urinish. Biroz kutib qaytib keling",
        _ => "Xato yuz berdi. Qaytadan urinib ko'ring",
      };

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profile = LocalStore.instance.getSkinProfile();
    final top = MediaQuery.of(context).padding.top;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthDeleted) _clearAndExit();
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: top + 12)),

          // ── Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hisob',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Avatar + email ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_email.isNotEmpty) ...[
                    Text(
                      _email,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ] else
                    Text(
                      'Real Beauty foydalanuvchisi',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ── Skin profile card ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionCard(
                title: 'TERI PROFILI',
                child: profile != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              profile.skinType,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            profile.baseRecommendation,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: AppColors.muted,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ActionRow(
                            icon: Icons.refresh_rounded,
                            label: 'Tahlilni qayta o\'tkazish',
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
                          const SizedBox(height: 14),
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

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Account actions ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionCard(
                title: 'HISOB',
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.logout_rounded,
                      label: 'Chiqish',
                      onTap: _confirmLogout,
                    ),
                    const Divider(height: 24, color: Color(0xFFF0ECF8)),
                    _ActionRow(
                      icon: _actionLoading
                          ? Icons.hourglass_empty_rounded
                          : Icons.delete_outline_rounded,
                      label: _actionLoading
                          ? "O'chirilmoqda..."
                          : "Akkauntni o'chirish",
                      color: Colors.red.shade400,
                      onTap: _actionLoading ? () {} : _confirmDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      ),
    );
  }
}

// ── Re-auth sheet ─────────────────────────────────────────────

class _ReAuthSheet extends StatefulWidget {
  final String email;
  final ScaffoldMessengerState messenger;

  const _ReAuthSheet({required this.email, required this.messenger});

  @override
  State<_ReAuthSheet> createState() => _ReAuthSheetState();
}

class _ReAuthSheetState extends State<_ReAuthSheet> {
  late final TextEditingController _emailCtrl;
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final pass = _passCtrl.text;
    if (pass.isEmpty) {
      setState(() => _error = "Parolni kiriting");
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    context.read<AuthCubit>().reauthenticateAndDelete(pass);
  }

  void _forgotPassword() {
    context.read<AuthCubit>().sendPasswordReset(widget.email);
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
        } else if (state is AuthInfo) {
          setState(() => _loading = false);
          widget.messenger.showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: GoogleFonts.nunito(fontSize: 13, color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 5),
            ),
          );
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
              "Akkauntni o'chirish uchun parolingizni kiriting.",
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _AuthField(
              controller: _emailCtrl,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            const SizedBox(height: 12),
            _AuthField(
              controller: _passCtrl,
              hint: 'Parol',
              obscure: true,
            ),
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
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: _loading ? null : _forgotPassword,
                child: Text(
                  "Parolni unutdingizmi?",
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
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
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        "Tasdiqlab o'chirish",
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirm dialog (reusable) ─────────────────────────────────

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

// ── Section card ─────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Action row ────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final c = color ?? AppColors.text;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: c.withValues(alpha: 0.45)),
        ],
      ),
    );
  }
}

// ── Compact text field used in re-auth dialog ─────────────────

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool readOnly;
  final TextInputType keyboardType;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      keyboardType: keyboardType,
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
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
