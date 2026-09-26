import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/business_profile.dart';
import '../blocs/app_bloc.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});
  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _tin;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _prefix;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppBloc>().state.profile;
    _name = TextEditingController(text: profile.businessName);
    _tin = TextEditingController(text: profile.tin);
    _address = TextEditingController(text: profile.address);
    _phone = TextEditingController(text: profile.phone);
    _email = TextEditingController(text: profile.email);
    _prefix = TextEditingController(text: profile.invoicePrefix);
  }

  @override
  void dispose() {
    _name.dispose();
    _tin.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _prefix.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Business Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            Text('This information appears on every invoice you issue and is required for NRS/FIRS e-invoice validation.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            const Gap(20),
            _field(_name, 'Business name', required: true),
            const Gap(12),
            _field(_tin, 'Tax Identification Number (TIN)', required: true),
            const Gap(12),
            _field(_address, 'Business address', required: true, maxLines: 2),
            const Gap(12),
            _field(_phone, 'Phone number', keyboardType: TextInputType.phone),
            const Gap(12),
            _field(_email, 'Email', keyboardType: TextInputType.emailAddress),
            const Gap(12),
            _field(_prefix, 'Invoice prefix (e.g. INV)'),
            const Gap(24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Profile'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final profile = BusinessProfile(
      businessName: _name.text.trim(),
      tin: _tin.text.trim(),
      address: _address.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      invoicePrefix: _prefix.text.trim().isEmpty ? 'INV' : _prefix.text.trim(),
    );
    context.read<AppBloc>().add(ProfileSaved(profile));
    Navigator.pop(context);
  }
}
