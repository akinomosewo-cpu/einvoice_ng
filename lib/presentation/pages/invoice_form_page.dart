import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/product.dart';
import '../blocs/app_bloc.dart';
import '../widgets/success_check.dart';

/// Invoice creation form covering the fields a government-approved e-invoice
/// layout requires: seller/buyer TIN & address, sequential invoice number,
/// itemised VAT per line, issue/due dates.
class InvoiceFormPage extends StatefulWidget {
  const InvoiceFormPage({super.key});
  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceItemDraft {
  String description = '';
  double quantity = 1;
  double unitPrice = 0;
  VatRate vatRate = VatRate.sevenpointfive;
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  late final TextEditingController _invoiceNumber;
  Customer? _selectedCustomer;
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _customerTin = TextEditingController();
  final TextEditingController _customerAddress = TextEditingController();
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  final List<_InvoiceItemDraft> _items = [_InvoiceItemDraft()];

  double get _subtotal => _items.fold(0.0, (s, i) => s + i.quantity * i.unitPrice);
  double get _totalVat => _items.fold(0.0, (s, i) => s + i.quantity * i.unitPrice * vatRateToPercent(i.vatRate));
  double get _grandTotal => _subtotal + _totalVat;

  @override
  void initState() {
    super.initState();
    _invoiceNumber = TextEditingController(text: context.read<AppBloc>().suggestNextInvoiceNumber());
  }

  @override
  void dispose() {
    _invoiceNumber.dispose();
    _customerName.dispose();
    _customerTin.dispose();
    _customerAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppBloc>().state;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('New Invoice')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionLabel('Invoice details'),
          TextField(
            controller: _invoiceNumber,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Invoice number'),
          ),
          const Gap(12),
          Row(children: [
            Expanded(child: _dateField('Issue date', _issueDate, (d) => setState(() => _issueDate = d))),
            const Gap(12),
            Expanded(child: _dateField('Due date', _dueDate, (d) => setState(() => _dueDate = d))),
          ]),
          const Gap(24),
          _sectionLabel('Buyer'),
          if (state.customers.isNotEmpty)
            DropdownButtonFormField<Customer?>(
              value: _selectedCustomer,
              dropdownColor: AppColors.surfaceElevated,
              decoration: const InputDecoration(labelText: 'Select saved customer (optional)'),
              items: [
                const DropdownMenuItem<Customer?>(value: null, child: Text('New / one-off customer')),
                ...state.customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
              ],
              onChanged: (c) => setState(() {
                _selectedCustomer = c;
                _customerName.text = c?.name ?? '';
                _customerTin.text = c?.tin ?? '';
                _customerAddress.text = c?.address ?? '';
              }),
            ),
          const Gap(12),
          TextField(controller: _customerName, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Buyer name')),
          const Gap(12),
          TextField(controller: _customerTin, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Buyer TIN')),
          const Gap(12),
          TextField(controller: _customerAddress, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(labelText: 'Buyer address')),
          const Gap(24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _sectionLabel('Line items'),
            TextButton.icon(
              onPressed: () => setState(() => _items.add(_InvoiceItemDraft())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add item'),
            ),
          ]),
          ..._items.asMap().entries.map((e) => _ItemRow(
                key: ValueKey(e.key),
                draft: e.value,
                products: state.products,
                onChanged: () => setState(() {}),
                onRemove: _items.length > 1 ? () => setState(() => _items.removeAt(e.key)) : null,
              )),
          const Gap(20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              _totalRow('Subtotal', _subtotal),
              _totalRow('Total VAT', _totalVat),
              const Divider(),
              _totalRow('Grand Total', _grandTotal, bold: true),
            ]),
          ),
          const Gap(24),
          ElevatedButton(onPressed: _save, child: const Text('Create Invoice')),
          const Gap(20),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
      );

  Widget _totalRow(String label, double value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: (bold ? AppTextStyles.headlineSmall : AppTextStyles.bodyMedium).copyWith(color: AppColors.textPrimary)),
          Text('₦${value.toStringAsFixed(2)}', style: (bold ? AppTextStyles.headlineSmall : AppTextStyles.bodyMedium).copyWith(color: bold ? AppColors.primary : AppColors.textSecondary)),
        ]),
      );

  Widget _dateField(String label, DateTime value, ValueChanged<DateTime> onPicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text('${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
      ),
    );
  }

  void _save() {
    final bloc = context.read<AppBloc>();
    final profile = bloc.state.profile;
    if (_invoiceNumber.text.trim().isEmpty || _customerName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice number and buyer name are required.')));
      return;
    }
    final validItems = _items.where((i) => i.description.trim().isNotEmpty && i.quantity > 0).toList();
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one line item.')));
      return;
    }
    final existingNumbers = bloc.state.invoices.map((i) => i.invoiceNumber).toList();
    if (existingNumbers.any((n) => n.toUpperCase() == _invoiceNumber.text.trim().toUpperCase())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That invoice number is already in use.')));
      return;
    }
    final uuid = const Uuid();
    final invoice = Invoice(
      id: uuid.v4(),
      invoiceNumber: _invoiceNumber.text.trim(),
      buyerName: _customerName.text.trim(),
      buyerTin: _customerTin.text.trim(),
      buyerAddress: _customerAddress.text.trim(),
      sellerName: profile.businessName,
      sellerTin: profile.tin,
      sellerAddress: profile.address,
      items: validItems
          .map((i) => InvoiceItem(id: uuid.v4(), description: i.description.trim(), quantity: i.quantity, unitPrice: i.unitPrice, vatRate: i.vatRate))
          .toList(),
      issueDate: _issueDate,
      dueDate: _dueDate,
      status: InvoiceStatus.draft,
    );
    bloc.add(InvoiceCreated(invoice));
    unawaited(showSuccessOverlay(context, message: 'Invoice created'));
    Navigator.pop(context);
  }
}

class _ItemRow extends StatefulWidget {
  final _InvoiceItemDraft draft;
  final List<Product> products;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;
  const _ItemRow({super.key, required this.draft, required this.products, required this.onChanged, this.onRemove});
  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  late final TextEditingController _desc = TextEditingController(text: widget.draft.description);
  late final TextEditingController _qty = TextEditingController(text: widget.draft.quantity == 1 ? '1' : widget.draft.quantity.toString());
  late final TextEditingController _price = TextEditingController(text: widget.draft.unitPrice == 0 ? '' : widget.draft.unitPrice.toString());

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        if (widget.products.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<Product>(
              hint: const Text('Pick from catalog'),
              dropdownColor: AppColors.surfaceElevated,
              underline: const SizedBox.shrink(),
              items: widget.products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
              onChanged: (p) {
                if (p == null) return;
                setState(() {
                  _desc.text = p.name;
                  _price.text = p.unitPrice.toString();
                  widget.draft.description = p.name;
                  widget.draft.unitPrice = p.unitPrice;
                  widget.draft.vatRate = p.vatRate;
                });
                widget.onChanged();
              },
            ),
          ),
        TextField(
          controller: _desc,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Description'),
          onChanged: (v) {
            widget.draft.description = v;
            widget.onChanged();
          },
        ),
        const Gap(10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _qty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Qty'),
              onChanged: (v) {
                widget.draft.quantity = double.tryParse(v) ?? 0;
                widget.onChanged();
              },
            ),
          ),
          const Gap(10),
          Expanded(
            child: TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Unit price'),
              onChanged: (v) {
                widget.draft.unitPrice = double.tryParse(v) ?? 0;
                widget.onChanged();
              },
            ),
          ),
          const Gap(10),
          DropdownButton<VatRate>(
            value: widget.draft.vatRate,
            dropdownColor: AppColors.surfaceElevated,
            items: VatRate.values.map((r) => DropdownMenuItem(value: r, child: Text('${(vatRateToPercent(r) * 100).toStringAsFixed(1)}%'))).toList(),
            onChanged: (r) {
              setState(() => widget.draft.vatRate = r ?? widget.draft.vatRate);
              widget.onChanged();
            },
          ),
          if (widget.onRemove != null)
            IconButton(icon: const Icon(Icons.close, color: AppColors.danger, size: 18), onPressed: widget.onRemove),
        ]),
      ]),
    );
  }
}
