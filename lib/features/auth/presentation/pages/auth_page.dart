import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:real_beauty_ai/core/constants/api_constants.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/widgets/google_sign_in_button.dart';

void _openPrivacyPolicy() {
  launchUrl(Uri.parse(privacyPolicyUrl), mode: LaunchMode.externalApplication);
}

// Real email format check — used by both login and register email fields.
final _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
String? _validateEmail(String? v) {
  final value = v?.trim() ?? '';
  if (value.isEmpty) return 'Email kiriting';
  if (!_emailPattern.hasMatch(value)) return 'Haqiqiy email kiriting';
  return null;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _page = PageController();

  void _toRegister() => _page.animateToPage(
        1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );

  void _toLogin() => _page.animateToPage(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.nunito(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF7060AA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          HapticFeedback.mediumImpact();
          context.go('/home');
        } else if (state is AuthError) {
          _showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _page,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _LoginPage(
              onSignUp: _toRegister,
              onForgotPassword: () => context.push('/forgot'),
            ),
            _RegisterPage(onLogin: _toLogin),
          ],
        ),
      ),
    );
  }
}

// ── Shared header ────────────────────────────────────────────

class _AuthHeader extends StatelessWidget {
  final String title;
  const _AuthHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Image.asset('assets/splash.png', height: 104)),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3D2F8A),
          ),
        ),
      ],
    );
  }
}

// ── Login Page ───────────────────────────────────────────────

class _LoginPage extends StatefulWidget {
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;
  const _LoginPage({required this.onSignUp, required this.onForgotPassword});

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(_emailCtrl.text, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;

    return Form(
      key: _formKey,
      autovalidateMode:
          _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: AutofillGroup(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, top + 20, 28, bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthHeader(title: 'Xush kelibsiz'),
              const SizedBox(height: 24),
              _AuthField(
                label: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                controller: _emailCtrl,
                validator: _validateEmail,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 12),
              _AuthField(
                label: 'Parol',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Parol kiriting';
                  return null;
                },
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(context),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onForgotPassword,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Parolni unutdingizmi?',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7060AA),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return _AuthButton(
                    label: 'Kirish',
                    isLoading: state is AuthLoading,
                    onTap: () => _submit(context),
                  );
                },
              ),
              const SizedBox(height: 16),
              const _OrDivider(),
              const SizedBox(height: 16),
              const GoogleSignInButton(),
              const SizedBox(height: 20),
              _SwitchRow(
                text: "Hisobingiz yo'qmi?",
                actionText: "Ro'yxatdan o'tish",
                onTap: widget.onSignUp,
              ),
              const SizedBox(height: 12),
              const _PrivacyLink(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Register Page ────────────────────────────────────────────

class _RegisterPage extends StatefulWidget {
  final VoidCallback onLogin;
  const _RegisterPage({required this.onLogin});

  @override
  State<_RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<_RegisterPage> {
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().register(_emailCtrl.text, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;

    return Form(
      key: _formKey,
      autovalidateMode:
          _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: AutofillGroup(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, top + 20, 28, bottom + 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthHeader(title: 'Hisob yaratish'),
              const SizedBox(height: 24),
              _AuthField(
                label: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                controller: _emailCtrl,
                validator: _validateEmail,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 12),
              _AuthField(
                label: 'Parol',
                helperText: 'Kamida 6 belgi',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Parol kiriting';
                  if (v.length < 6) return "Parol kamida 6 belgidan iborat bo'lishi kerak";
                  return null;
                },
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onFieldSubmitted: (_) => _submit(context),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return _AuthButton(
                    label: "Ro'yxatdan o'tish",
                    isLoading: state is AuthLoading,
                    onTap: () => _submit(context),
                  );
                },
              ),
              const SizedBox(height: 16),
              const _OrDivider(),
              const SizedBox(height: 16),
              const GoogleSignInButton(),
              const SizedBox(height: 20),
              _SwitchRow(
                text: 'Hisobingiz bormi?',
                actionText: 'Kirish',
                onTap: widget.onLogin,
              ),
              const SizedBox(height: 12),
              const _PrivacyLink(),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────

/// Floating-label field: the label sits inside the box and rises onto the
/// border on focus, so every input stays self-describing without the extra
/// stacked label row that stretched this screen vertically.
class _AuthField extends StatelessWidget {
  final String label;
  final String? helperText;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final void Function(String)? onFieldSubmitted;

  const _AuthField({
    required this.label,
    required this.icon,
    this.helperText,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      style: GoogleFonts.nunito(
        fontSize: 15,
        color: AppColors.text,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        labelStyle: GoogleFonts.nunito(
          fontSize: 15,
          color: const Color(0xFF9490B0),
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: const Color(0xFF7060AA),
          fontWeight: FontWeight.w700,
        ),
        helperStyle: GoogleFonts.nunito(
          fontSize: 11,
          color: const Color(0xFFB3AFC7),
        ),
        errorStyle: GoogleFonts.nunito(fontSize: 11),
        prefixIcon: Icon(icon, color: const Color(0xFFBBB8D0), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F7FC),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE8F5), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE8F5), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7060AA), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.8),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  const _AuthButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A3A9A),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF4A3A9A).withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;
  const _SwitchRow({
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: const Color(0xFF9490B0),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Text(
              actionText,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A3A9A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: 1, color: const Color(0xFFEAE8F5)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'yoki',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFB3AFC7),
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class _PrivacyLink extends StatelessWidget {
  const _PrivacyLink();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _openPrivacyPolicy,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Text(
            'Maxfiylik siyosati',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9490B0),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
