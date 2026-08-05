import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';

/// Holding screen for a signed-in account whose address is not proven yet.
///
/// Clicking the link happens outside the app, and `authStateChanges()` stays
/// silent when it does — so this screen polls the Auth record. Once the flag
/// flips, [AuthBloc] emits and the router redirect moves the user on; nothing
/// here navigates by itself.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _pollInterval = Duration(seconds: 4);
  // Firebase rejects repeat sends in quick succession with too-many-requests;
  // the button stays disabled long enough that the user never triggers it.
  static const _resendCooldown = Duration(seconds: 60);

  Timer? _poll;
  Timer? _cooldownTicker;
  int _cooldownLeft = 0;

  @override
  void initState() {
    super.initState();
    _poll = Timer.periodic(_pollInterval, (_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthRefreshRequested());
    });
    _startCooldown();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _cooldownTicker?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTicker?.cancel();
    setState(() => _cooldownLeft = _resendCooldown.inSeconds);
    _cooldownTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _cooldownLeft--);
      if (_cooldownLeft <= 0) timer.cancel();
    });
  }

  void _resend() {
    HapticFeedback.mediumImpact();
    context.read<AuthCubit>().resendEmailVerification();
    _startCooldown();
  }

  void _checkNow() {
    HapticFeedback.selectionClick();
    context.read<AuthBloc>().add(const AuthRefreshRequested());
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.nunito(color: Colors.white)),
        backgroundColor: const Color(0xFF7060AA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthBloc, String>(
      (bloc) => switch (bloc.state) {
        AuthAuthenticatedSession(:final user) => user.email ?? '',
        _ => '',
      },
    );
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInfo) _showSnack(state.message);
        if (state is AuthError) _showSnack(state.message);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, top + 40, 28, bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/splash.png', height: 104)),
              const SizedBox(height: 32),
              Text(
                'Emailingizni tasdiqlang',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3D2F8A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                email.isEmpty
                    ? 'Emailingizga tasdiqlash havolasini yubordik.'
                    : '$email manziliga tasdiqlash havolasini yubordik.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: const Color(0xFF9490B0),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Havolani bosing — ilova o'zi davom etadi.\n"
                "Xat kelmasa, spam papkasini tekshiring.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: const Color(0xFFB3AFC7),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _checkNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3A9A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Tasdiqladim',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: TextButton(
                  onPressed: _cooldownLeft > 0 ? null : _resend,
                  child: Text(
                    _cooldownLeft > 0
                        ? "Qayta yuborish ($_cooldownLeft s)"
                        : 'Havolani qayta yuborish',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _cooldownLeft > 0
                          ? const Color(0xFFB3AFC7)
                          : const Color(0xFF7060AA),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => context.read<AuthCubit>().logout(),
                  child: Text(
                    'Boshqa hisob bilan kirish',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
