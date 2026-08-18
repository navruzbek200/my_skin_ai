import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';

/// Blocks entry until the address is confirmed. Reached only by password
/// accounts — Google sign-ins arrive with `emailVerified` already true, so
/// the router guard never routes them here.
///
/// `authStateChanges()` never fires when the link is clicked in a mail
/// client — the flag only changes on the Auth record — so this screen polls
/// with [AuthRefreshRequested] instead of waiting on the stream.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with WidgetsBindingObserver {
  static const _throttleSeconds = 30;

  Timer? _poll;
  Timer? _countdown;
  bool _resending = false;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    _countdown?.cancel();
    super.dispose();
  }

  /// The link is opened in a mail client, which means the app is backgrounded
  /// at the moment it is clicked — polling through that window spends battery
  /// and Auth quota on a flag that provably cannot have changed yet. Coming
  /// back is the first moment it can have, so that is when we look.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
      _startPolling();
      return;
    }
    _poll?.cancel();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
  }

  void _refresh() => context.read<AuthBloc>().add(const AuthRefreshRequested());

  /// Offered because the address is wrong, so the record is unreachable: no
  /// link can arrive at it and no reset can either. Signing out alone would
  /// leave it holding the mistyped address forever, so this deletes it —
  /// nothing of the person's is on the server, their skin profile and history
  /// live on the device and survive the new sign-up untouched.
  Future<void> _startOver() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Boshqa email bilan boshlaysizmi?',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3D2F8A),
          ),
        ),
        content: Text(
          "Bu akkaunt o'chiriladi va siz yangi email bilan ro'yxatdan "
          "o'tasiz. Teri profilingiz va skan tarixingiz qurilmada saqlanib "
          'qoladi.',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: const Color(0xFF6F6A8C),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Bekor qilish',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF9490B0),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Ha, boshqa email',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A3A9A),
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthCubit>().abandonUnverifiedAccount();
  }

  void _notify(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        backgroundColor:
            isError ? const Color(0xFFC0564F) : const Color(0xFF7060AA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _resend() {
    if (_remaining > 0 || _resending) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _resending = true;
      _remaining = _throttleSeconds;
    });
    context.read<AuthCubit>().sendEmailVerification();
    // Visible countdown so a disabled button reads as "wait 30s", not "broken".
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _remaining--);
      if (_remaining <= 0) timer.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final email = context.watch<AuthCubit>().currentEmail ?? '';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Failures have to be spoken aloud here. This screen cannot be walked
        // away from, so a resend that silently dies — rate limited, offline —
        // leaves the person watching a spinner stop and an inbox stay empty
        // with nothing to explain either.
        if (state is AuthInfo) {
          setState(() => _resending = false);
          _notify(state.message, isError: false);
        } else if (state is AuthError) {
          setState(() => _resending = false);
          _notify(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, top + 24, 28, bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/splash.png', height: 104)),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEDE9F8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: Color(0xFF7060AA),
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Emailingizni tasdiqlang',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF3D2F8A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$email manziliga tasdiqlash havolasi yuborildi.\n'
                'Havolani bosgach, shu sahifa avtomatik davom etadi. '
                "Xat kelmasa yoki eskirgan bo'lsa, quyidagi tugmani bosing.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: const Color(0xFF9490B0),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _remaining > 0 || _resending ? null : _resend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A3A9A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFF4A3A9A).withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _resending && _remaining == _throttleSeconds
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          _remaining > 0
                              ? "Qayta yuborish ($_remaining)"
                              : 'Havolani qayta yuborish',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: _startOver,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Email xato kiritdingizmi? Boshqa email bilan boshlash',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9490B0),
                      ),
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
