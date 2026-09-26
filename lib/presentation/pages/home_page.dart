import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/invoice.dart';
import '../blocs/app_bloc.dart';
import 'business_profile_page.dart';
import 'customers_page.dart';
import 'invoice_detail_page.dart';
import 'invoice_form_page.dart';
import 'products_page.dart';
import 'subscription_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AppBloc>().add(const AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: AppColors.background,
                  title: Row(children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 17),
                    ),
                    const Gap(10),
                    Text('E-Invoice NG', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
                  ]),
                  actions: [
                    IconButton(
                      tooltip: 'Business profile',
                      icon: const Icon(Icons.storefront_outlined, color: AppColors.textSecondary),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BusinessProfilePage()),
                      ),
                    ),
                    IconButton(
                      tooltip: 'New invoice',
                      icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                      onPressed: () => _newInvoice(context),
                    ),
                    const Gap(4),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (!state.profile.isComplete)
                        _ProfileNudge(onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BusinessProfilePage()),
                        )),
                      const Gap(12),
                      Row(children: [
                        _StatCard(label: 'Invoices', value: state.invoices.length.toString(), color: AppColors.primary)
                            .animate(delay: 50.ms)
                            .fadeIn()
                            .slideY(begin: 0.1),
                        const Gap(12),
                        _StatCard(label: 'Paid', value: '₦${state.totalRevenue.toStringAsFixed(0)}', color: AppColors.success)
                            .animate(delay: 100.ms)
                            .fadeIn()
                            .slideY(begin: 0.1),
                        const Gap(12),
                        _StatCard(label: 'VAT Collected', value: '₦${state.totalVatCollected.toStringAsFixed(0)}', color: AppColors.warning)
                            .animate(delay: 150.ms)
                            .fadeIn()
                            .slideY(begin: 0.1),
                      ]),
                      const Gap(28),
                      Text('Manage', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                      const Gap(12),
                      _FeatureCard(
                        icon: Icons.people_outline_rounded,
                        label: 'Customers (${state.customers.length})',
                        color: AppColors.primary,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersPage())),
                      ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1),
                      const Gap(8),
                      _FeatureCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Products & Services (${state.products.length})',
                        color: AppColors.success,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsPage())),
                      ).animate(delay: 250.ms).fadeIn().slideX(begin: -0.1),
                      const Gap(8),
                      _FeatureCard(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Subscription plan',
                        color: AppColors.warning,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPage())),
                      ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.1),
                      const Gap(24),
                      Text('Invoice History', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                      const Gap(12),
                      if (state.invoices.isEmpty)
                        SoftCard(
                          radius: 28,
                          padding: const EdgeInsets.all(32),
                          child: Column(children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 34),
                            ),
                            const Gap(16),
                            Text('No invoices yet', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                            const Gap(4),
                            Text('Tap + to create your first invoice', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary)),
                          ]),
                        ).animate().fadeIn(delay: 350.ms),
                      ...state.invoices.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _InvoiceTile(
                              invoice: e.value,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => InvoiceDetailPage(invoiceId: e.value.id)),
                              ),
                              onDelete: () => context.read<AppBloc>().add(InvoiceDeleted(e.value.id)),
                            ).animate(delay: Duration(milliseconds: 50 * e.key)).fadeIn(),
                          )),
                      const Gap(32),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _newInvoice(BuildContext context) {
    final bloc = context.read<AppBloc>();
    if (!bloc.state.profile.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set up your business profile (name & TIN) before creating invoices.')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessProfilePage()));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: bloc, child: const InvoiceFormPage())));
  }
}

class _ProfileNudge extends StatelessWidget {
  final VoidCallback onTap;
  const _ProfileNudge({required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
              const Gap(12),
              Expanded(
                child: Text('Complete your business profile to start invoicing',
                    style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.warning),
            ]),
          ),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: SoftCard(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(children: [
            Text(value, style: AppTextStyles.headlineLarge.copyWith(color: color, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
            const Gap(4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FeatureCard({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SoftCard(
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 18),
            ),
            const Gap(14),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
          ]),
        ),
      );
}

class _InvoiceTile extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _InvoiceTile({required this.invoice, required this.onTap, required this.onDelete});

  Color _statusColor() {
    switch (invoice.status) {
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.sent:
        return AppColors.warning;
      case InvoiceStatus.validated:
        return AppColors.primary;
      case InvoiceStatus.draft:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    return Dismissible(
      key: Key(invoice.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.16), borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SoftCard(
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(invoice.invoiceNumber, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                Text(invoice.buyerName, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                Text('₦${invoice.grandTotal.toStringAsFixed(2)}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary)),
              ]),
            ),
            StatusChip(label: invoice.status.name, color: statusColor),
          ]),
        ),
      ),
    );
  }
}
