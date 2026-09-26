import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A small checkmark that scales in with a spring-like overshoot, used for
/// quick, non-blocking success feedback (invoice created, marked paid, ...).
class SuccessCheck extends StatefulWidget {
  final double size;
  const SuccessCheck({super.key, this.size = 72});

  @override
  State<SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<SuccessCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), shape: BoxShape.circle),
        child: Icon(Icons.check_rounded, color: AppColors.success, size: widget.size * 0.55),
      ),
    );
  }
}

/// Shows a brief, non-blocking overlay with a [SuccessCheck] and [message],
/// dismissing itself automatically after [duration].
Future<void> showSuccessOverlay(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(milliseconds: 900),
}) async {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 200),
            builder: (context, value, child) => Opacity(opacity: value, child: child),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SuccessCheck(),
                  const SizedBox(height: 12),
                  Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), textAlign: TextAlign.center),
                ]),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  await Future.delayed(duration);
  entry.remove();
}
