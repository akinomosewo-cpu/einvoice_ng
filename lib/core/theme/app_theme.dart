import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warm, soft light palette inspired by modern consumer-app design:
/// off-white backgrounds, a single vibrant brand accent, generous
/// rounding and soft shadows instead of flat borders.
class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF6C5CE6);
  static const Color primaryDark = Color(0xFF4B3FBF);
  static const Color success = Color(0xFF1FAA59);
  static const Color warning = Color(0xFFE8A400);
  static const Color danger = Color(0xFFE5484D);

  // Warm off-white app background + card surfaces.
  static const Color background = Color(0xFFFBF6EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFF3EEE4);

  static const Color textPrimary = Color(0xFF211E2B);
  static const Color textSecondary = Color(0xFF6F6A7C);
  static const Color textTertiary = Color(0xFFACA6B8);
  static const Color border = Color(0xFFEDE7DA);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE6), Color(0xFF9B7CF0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft, diffuse shadow used in place of flat borders on cards.
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF211E2B).withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF211E2B).withOpacity(0.05),
      blurRadius: 14,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Semantic colors for invoice status chips.
  static Color statusColor(String status) {
    switch (status) {
      case 'paid':
        return success;
      case 'sent':
        return warning;
      case 'validated':
        return primary;
      case 'draft':
      default:
        return textSecondary;
    }
  }
}

class AppTextStyles {
  AppTextStyles._();
  static TextStyle get displayLarge => GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.05);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.1);
  static TextStyle get displaySmall => GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700);
  static TextStyle get headlineMedium => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700);
  static TextStyle get headlineSmall => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600);
  static TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600);
  static TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3);
}

class AppTheme {
  AppTheme._();
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: AppTextStyles.headlineSmall,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: AppTextStyles.headlineSmall,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceTint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );

  /// Kept for compatibility with any leftover dark-mode references.
  static ThemeData get dark => light;
}

/// A generously-rounded card with a soft shadow instead of a flat border,
/// matching the reference design language used across the app.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<BoxShadow>? shadow;
  final Color color;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.shadow,
    this.color = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ?? AppColors.softShadow,
      ),
      child: child,
    );
  }
}

/// A colorful, rounded pill used for invoice status and other semantic tags.
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
