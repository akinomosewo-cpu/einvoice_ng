import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/customer.dart';
import '../blocs/app_bloc.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(icon: const Icon(Icons.add_rounded), onPressed: () => _showEditor(context)),
        ],
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state.customers.isEmpty) {
            return Center(
              child: Text('No customers yet. Tap + to add one.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.customers.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, i) {
              final c = state.customers[i];
              return Dismissible(
                key: Key(c.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                ),
                onDismissed: (_) => context.read<AppBloc>().add(CustomerDeleted(c.id)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(c.name, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                    subtitle: Text('TIN: ${c.tin.isEmpty ? "—" : c.tin}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    onTap: () => _showEditor(context, existing: c),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditor(BuildContext context, {Customer? existing}) {
    final bloc = context.read<AppBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: bloc, child: _CustomerEditor(existing: existing)),
    );
  }
}

class _CustomerEditor extends StatefulWidget {
  final Customer? existing;
  const _CustomerEditor({this.existing});
  @override
  State<_CustomerEditor> createState() => _CustomerEditorState();
}

class _CustomerEditorState extends State<_CustomerEditor> {
  late final TextEditingController _name = TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _tin = TextEditingController(text: widget.existing?.tin ?? '');
  late final TextEditingController _address = TextEditingController(text: widget.existing?.address ?? '');
  late final TextEditingController _phone = TextEditingController(text: widget.existing?.phone ?? '');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.existing == null ? 'Add Customer' : 'Edit Customer', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
        const Gap(20),
        TextField(controller: _name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(hintText: 'Customer / business name')),
        const Gap(12),
        TextField(controller: _tin, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(hintText: 'TIN (for VAT-claimable invoices)')),
        const Gap(12),
        TextField(controller: _address, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(hintText: 'Address')),
        const Gap(12),
        TextField(controller: _phone, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary), decoration: const InputDecoration(hintText: 'Phone')),
        const Gap(20),
        ElevatedButton(
          onPressed: () {
            if (_name.text.trim().isEmpty) return;
            final customer = Customer(
              id: widget.existing?.id ?? const Uuid().v4(),
              name: _name.text.trim(),
              tin: _tin.text.trim(),
              address: _address.text.trim(),
              phone: _phone.text.trim(),
            );
            context.read<AppBloc>().add(CustomerSaved(customer));
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ]),
    );
  }
}
