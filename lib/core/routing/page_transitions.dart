import 'package:flutter/material.dart';

/// A short fade+slide transition used for the major flow transitions in the
/// app (splash -> auth -> dashboard). Kept brief and non-blocking so it never
/// gets in the way of the underlying navigation.
class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  FadeSlidePageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
                child: child,
              ),
            );
          },
        );
}

Future<T?> pushFadeSlide<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).push<T>(FadeSlidePageRoute<T>(builder: builder));
}

Future<T?> pushReplacementFadeSlide<T, TO>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).pushReplacement<T, TO>(FadeSlidePageRoute<T>(builder: builder));
}
