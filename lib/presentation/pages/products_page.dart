import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/product.dart';
import '../blocs/app_bloc.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products & Services'),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _showEditor(context)),
        ],
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state.products.isEmpty) {
            return Center(
              child: Text('No products yet. Tap + to add one.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.products.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, i) {
              final p = state.products[i];
              return Dismissible(
                key: Key(p.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                ),
                onDismissed: (_) => context.read<AppBloc>().add(ProductDeleted(p.id)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.name, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                    subtitle: Text('₦${p.unitPrice.toStringAsFixed(2)} · VAT ${(vatRateToPercent(p.vatRate) * 100).toStringAsFixed(1)}%',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    onTap: () => _showEditor(context, existing: p),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditor(BuildContext context, {Product? existing}) {
    final bloc = context.read<AppBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: bloc, child: _ProductEditor(existing: existing)),
    );
  }
}

class _ProductEditor extends StatefulWidget {
  final Product? existing;
  const _ProductEditor({this.existing});
  @override
  State<_ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<_ProductEditor> {
  late final TextEditingController _name = TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _price = TextEditingController(text: widget.existing?.unitPrice.toString() ?? '');
  late VatRate _rate = widget.existing?.vatRate ?? VatRate.sevenpointfive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.existing == null ? 'Add Product/Service' : 'Edit Product/Service', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
        const Gap(20),
        TextField(controller: _name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(hintText: 'Name')),
        const Gap(12),
        TextField(
          controller: _price,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Unit price (₦)'),
        ),
        const Gap(12),
        DropdownButtonFormField<VatRate>(
          value: _rate,
          dropdownColor: AppColors.surfaceElevated,
          decoration: const InputDecoration(labelText: 'VAT rate'),
          items: VatRate.values
              .map((r) => DropdownMenuItem(value: r, child: Text('${(vatRateToPercent(r) * 100).toStringAsFixed(1)}%')))
              .toList(),
          onChanged: (v) => setState(() => _rate = v ?? _rate),
        ),
        const Gap(20),
        ElevatedButton(
          onPressed: () {
            final price = double.tryParse(_price.text.trim());
            if (_name.text.trim().isEmpty || price == null) return;
            final product = Product(
              id: widget.existing?.id ?? const Uuid().v4(),
              name: _name.text.trim(),
              unitPrice: price,
              vatRate: _rate,
            );
            context.read<AppBloc>().add(ProductSaved(product));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ]),
    );
  }
}
