import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/routing/page_transitions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/auth_service.dart';
import '../home_page.dart';
import 'login_page.dart';

/// Animated brand splash shown on cold start. Reveals the app logo and name
/// with a short scale+fade, then checks whether the user is already
/// logged in before routing to the dashboard or the login screen.
class SplashPage extends StatefulWidget {
  final AuthService? authService;
  const SplashPage({super.key, this.authService});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final AuthService _authService;
  Timer? _revealTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _controller.forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Run the brand reveal (~1.5s total including the short pause at the
    // end) alongside auth storage init, so the splash never feels blocked
    // on IO but also never flashes by too fast to read.
    var loggedIn = false;
    try {
      await _authService.init();
      loggedIn = _authService.isLoggedIn;
    } catch (_) {
      // No platform channel for Hive (e.g. in widget tests) — fall back to
      // the login screen rather than crashing the splash.
    }
    // Use a cancelable Timer (rather than Future.delayed) so a disposed
    // splash never leaves a pending timer behind.
    _revealTimer = Timer(const Duration(milliseconds: 1500), () => _navigate(loggedIn));
  }

  void _navigate(bool loggedIn) {
    if (!mounted || _navigated) return;
    _navigated = true;
    if (loggedIn) {
      pushReplacementFadeSlide(context, (_) => const HomePage());
    } else {
      pushReplacementFadeSlide(context, (_) => LoginPage(authService: _authService));
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 20),
                Text('E-Invoice NG', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text('NRS-compliant invoicing for SMEs', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
