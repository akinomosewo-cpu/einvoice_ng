import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/services/invoice_pdf_service.dart';
import '../blocs/app_bloc.dart';

class InvoiceDetailPage extends StatelessWidget {
  final String invoiceId;
  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Invoice')),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final invoice = state.invoices.where((i) => i.id == invoiceId).cast<Invoice?>().firstOrNull;
          if (invoice == null) {
            return const Center(child: Text('Invoice not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(invoice.invoiceNumber, style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
                  DropdownButton<InvoiceStatus>(
                    value: invoice.status,
                    dropdownColor: AppColors.surfaceElevated,
                    items: InvoiceStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                    onChanged: (s) {
                      if (s != null) context.read<AppBloc>().add(InvoiceStatusUpdated(invoice.id, s));
                    },
                  ),
                ],
              ),
              const Gap(20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: QrImageView(
                    data: invoice.invoiceNumber,
                    version: QrVersions.auto,
                    size: 140,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Verification QR (placeholder for NRS invoice validation)',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary), textAlign: TextAlign.center),
                ),
              ),
              const Gap(24),
              _card('Seller', invoice.sellerName, invoice.sellerTin, invoice.sellerAddress),
              const Gap(12),
              _card('Buyer', invoice.buyerName, invoice.buyerTin, invoice.buyerAddress),
              const Gap(24),
              Text('Items', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
              const Gap(12),
              ...invoice.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                          Text('${item.quantity} × ₦${item.unitPrice.toStringAsFixed(2)} · VAT ${(vatRateToPercent(item.vatRate) * 100).toStringAsFixed(1)}%',
                              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                        ]),
                      ),
                      Text('₦${item.lineTotalWithVat.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                    ]),
                  )),
              const Gap(12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  _totalRow('Subtotal', invoice.subtotal),
                  _totalRow('Total VAT', invoice.totalVat),
                  const Divider(),
                  _totalRow('Grand Total', invoice.grandTotal, bold: true),
                ]),
              ),
              const Gap(24),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final doc = await const InvoicePdfService().build(invoice);
                      await Printing.sharePdf(bytes: await doc.save(), filename: '${invoice.invoiceNumber}.pdf');
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share PDF'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final doc = await const InvoicePdfService().build(invoice);
                      await Printing.layoutPdf(onLayout: (_) => doc.save());
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('View / Print'),
                  ),
                ),
              ]),
              const Gap(32),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String label, String name, String tin, String address) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          const Gap(4),
          Text(name, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
          Text('TIN: ${tin.isEmpty ? "—" : tin}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          if (address.isNotEmpty) Text(address, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
        ]),
      );

  Widget _totalRow(String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: (bold ? AppTextStyles.headlineSmall : AppTextStyles.bodyMedium).copyWith(color: AppColors.textPrimary)),
          Text('₦${value.toStringAsFixed(2)}', style: (bold ? AppTextStyles.headlineSmall : AppTextStyles.bodyMedium).copyWith(color: bold ? AppColors.primary : AppColors.textSecondary)),
        ]),
      );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
