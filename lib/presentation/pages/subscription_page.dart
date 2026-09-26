import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';

class _Plan {
  final String name;
  final int price;
  final List<String> features;
  final bool highlighted;
  const _Plan({required this.name, required this.price, required this.features, this.highlighted = false});
}

/// Subscription/paywall stub. No payment integration is wired up yet — this
/// screen exists to validate the pricing tiers and upgrade flow copy before
/// integrating a payment provider (e.g. Paystack/Flutterwave).
class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  static const _plans = [
    _Plan(name: 'Starter', price: 5000, features: ['Up to 30 invoices/month', 'Customer & product catalog', 'PDF export & share']),
    _Plan(name: 'Growth', price: 10000, features: ['Unlimited invoices', 'QR verification codes', 'Priority support'], highlighted: true),
    _Plan(name: 'Pro', price: 20000, features: ['Everything in Growth', 'Multi-user access', 'NRS e-invoice API sync (coming soon)']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Subscription')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Choose a plan', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
          const Gap(6),
          Text('Simple monthly pricing for small caterers, logistics operators and contractors.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const Gap(20),
          ..._plans.map((plan) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: plan.highlighted ? AppColors.primary : AppColors.border, width: plan.highlighted ? 1.5 : 1),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(plan.name, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
                      if (plan.highlighted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text('POPULAR', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                        ),
                    ]),
                    const Gap(4),
                    Text('₦${plan.price.toString()}/month', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary)),
                    const Gap(12),
                    ...plan.features.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(children: [
                            const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 16),
                            const Gap(8),
                            Expanded(child: Text(f, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
                          ]),
                        )),
                    const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${plan.name} plan checkout is coming soon.')),
                          );
                        },
                        child: const Text('Choose plan'),
                      ),
                    ),
                  ]),
                ),
              )),
          const Gap(8),
          Text('Payments are not yet enabled — this screen is a stub for the upcoming subscription flow.',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
