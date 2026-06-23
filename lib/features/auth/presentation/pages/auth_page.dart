import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/colors.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/widgets/google_sign_in_button.dart';

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
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
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
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(28, top + 60, 28, bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Image.asset('assets/logo.png', height: 110)),
            const SizedBox(height: 36),
            Text(
              'Xush kelibsiz',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3D2F8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Real Beauty bilan sayohatingizni davom ettiring",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF9490B0),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _AuthField(
              hint: 'Email manzil',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              controller: _emailCtrl,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email kiriting';
                if (!v.contains('@') || !v.contains('.')) return "Email format noto'g'ri";
                return null;
              },
            ),
            const SizedBox(height: 14),
            _AuthField(
              hint: 'Parol',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              controller: _passwordCtrl,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Parol kiriting';
                return null;
              },
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
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: widget.onForgotPassword,
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
            const SizedBox(height: 28),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return _AuthButton(
                  label: 'Kirish',
                  isLoading: state is AuthLoading,
                  onTap: () => _submit(context),
                );
              },
            ),
            const SizedBox(height: 20),
            const _OrDivider(),
            const SizedBox(height: 20),
            const GoogleSignInButton(),
            const SizedBox(height: 28),
            _SwitchRow(
              text: "Hisobingiz yo'qmi?",
              actionText: "Ro'yxatdan o'tish",
              onTap: widget.onSignUp,
            ),
          ],
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
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().register(
          _emailCtrl.text,
          _passwordCtrl.text,
          _firstNameCtrl.text,
          _lastNameCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final top = MediaQuery.of(context).padding.top;

    return Form(
      key: _formKey,
      autovalidateMode:
          _submitted ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(28, top + 60, 28, bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Image.asset('assets/logo.png', height: 110)),
            const SizedBox(height: 36),
            Text(
              'Hisob yaratish',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3D2F8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Real Beauty'ga qo'shiling va imtiyozlardan foydalaning",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF9490B0),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            _AuthField(
              hint: 'Ism',
              icon: Icons.person_outline_rounded,
              controller: _firstNameCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ism kiriting' : null,
            ),
            const SizedBox(height: 14),
            _AuthField(
              hint: 'Familiya',
              icon: Icons.person_outline_rounded,
              controller: _lastNameCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Familiya kiriting' : null,
            ),
            const SizedBox(height: 14),
            _AuthField(
              hint: 'Email manzil',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              controller: _emailCtrl,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email kiriting';
                if (!v.contains('@') || !v.contains('.')) return "Email format noto'g'ri";
                return null;
              },
            ),
            const SizedBox(height: 14),
            _AuthField(
              hint: 'Parol',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              controller: _passwordCtrl,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Parol kiriting';
                if (v.length < 6) return "Parol kamida 6 belgidan iborat bo'lishi kerak";
                return null;
              },
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
            const SizedBox(height: 28),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return _AuthButton(
                  label: "Ro'yxatdan o'tish",
                  isLoading: state is AuthLoading,
                  onTap: () => _submit(context),
                );
              },
            ),
            const SizedBox(height: 20),
            const _OrDivider(),
            const SizedBox(height: 20),
            const GoogleSignInButton(),
            const SizedBox(height: 28),
            _SwitchRow(
              text: 'Hisobingiz bormi?',
              actionText: 'Kirish',
              onTap: widget.onLogin,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────

class _AuthField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const _AuthField({
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.nunito(
        fontSize: 15,
        color: AppColors.text,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          fontSize: 15,
          color: const Color(0xFFBBB8D0),
        ),
        errorStyle: GoogleFonts.nunito(fontSize: 12),
        prefixIcon: Icon(icon, color: const Color(0xFFBBB8D0), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8F7FC),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFEAE8F5), thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'yoki',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: const Color(0xFF9490B0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFEAE8F5), thickness: 1.5)),
      ],
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
          child: Text(
            actionText,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A3A9A),
            ),
          ),
        ),
      ],
    );
  }
}
