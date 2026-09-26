import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/entities/business_profile.dart';
import '../domain/entities/customer.dart';
import '../domain/entities/invoice.dart';
import '../domain/entities/product.dart';

/// Thin persistence layer built on Hive boxes of JSON-encoded strings.
/// Deliberately avoids generated Hive adapters so the app builds without a
/// build_runner step.
class LocalStore {
  static const _profileBox = 'profile_box';
  static const _customersBox = 'customers_box';
  static const _productsBox = 'products_box';
  static const _invoicesBox = 'invoices_box';

  Box<String>? _profile;
  Box<String>? _customers;
  Box<String>? _products;
  Box<String>? _invoices;

  Future<void> init() async {
    await Hive.initFlutter();
    _profile = await Hive.openBox<String>(_profileBox);
    _customers = await Hive.openBox<String>(_customersBox);
    _products = await Hive.openBox<String>(_productsBox);
    _invoices = await Hive.openBox<String>(_invoicesBox);
  }

  // --- Business profile ---
  BusinessProfile? loadProfile() {
    final raw = _profile?.get('current');
    if (raw == null) return null;
    return BusinessProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    await _profile?.put('current', jsonEncode(profile.toJson()));
  }

  // --- Customers ---
  List<Customer> loadCustomers() {
    final box = _customers;
    if (box == null) return [];
    return box.values
        .map((raw) => Customer.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomer(Customer customer) async {
    await _customers?.put(customer.id, jsonEncode(customer.toJson()));
  }

  Future<void> deleteCustomer(String id) async {
    await _customers?.delete(id);
  }

  // --- Products ---
  List<Product> loadProducts() {
    final box = _products;
    if (box == null) return [];
    return box.values
        .map((raw) => Product.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProduct(Product product) async {
    await _products?.put(product.id, jsonEncode(product.toJson()));
  }

  Future<void> deleteProduct(String id) async {
    await _products?.delete(id);
  }

  // --- Invoices ---
  List<Invoice> loadInvoices() {
    final box = _invoices;
    if (box == null) return [];
    return box.values
        .map((raw) => Invoice.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveInvoice(Invoice invoice) async {
    await _invoices?.put(invoice.id, jsonEncode(invoice.toJson()));
  }

  Future<void> deleteInvoice(String id) async {
    await _invoices?.delete(id);
  }
}
