import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/routing/page_transitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/auth_service.dart';
import '../home_page.dart';
import 'login_page.dart';

/// Local sign-up screen: creates the single on-device business account.
/// Only a salted hash of the password is ever persisted (see [AuthService]).
class SignUpPage extends StatefulWidget {
  final AuthService authService;
  const SignUpPage({super.key, required this.authService});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await widget.authService.signUp(email: _email.text, password: _password.text);
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
                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
              ),
              const Gap(24),
              Text('Create your account', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
              const Gap(6),
              Text('Set up local access for your business', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your business email';
                      if (!v.contains('@')) return 'Enter a valid email address';
                      return null;
                    },
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
                    validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                  ),
                  const Gap(14),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Confirm password'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Confirm your password' : null,
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
                        : const Text('Sign up'),
                  ),
                ]),
              ),
              const Gap(20),
              Center(
                child: TextButton(
                  onPressed: () => pushReplacementFadeSlide(context, (_) => LoginPage(authService: widget.authService)),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(text: 'Log in', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
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
