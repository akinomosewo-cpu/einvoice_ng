import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/routing/page_transitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/auth_service.dart';
import '../home_page.dart';
import 'signup_page.dart';

/// Local sign-in screen. There is no backend: credentials are validated
/// against the salted hash stored on-device by [AuthService].
class LoginPage extends StatefulWidget {
  final AuthService authService;
  const LoginPage({super.key, required this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await widget.authService.login(email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (result.ok) {
      pushReplacementFadeSlide(context, (_) => const HomePage());
    } else {
      setState(() => _error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
              ),
              const Gap(24),
              Text('Welcome back', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
              const Gap(6),
              Text('Sign in to manage your invoices', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const Gap(32),
              SoftCard(
                radius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Business email'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your business email' : null,
                  ),
                  const Gap(14),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textTertiary),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter your password' : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const Gap(12),
                    Text(_error!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.danger)),
                  ],
                  const Gap(20),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Log in'),
                  ),
                ]),
              ),
              const Gap(20),
              Center(
                child: TextButton(
                  onPressed: () => pushReplacementFadeSlide(context, (_) => SignUpPage(authService: widget.authService)),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(text: 'Sign up', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
