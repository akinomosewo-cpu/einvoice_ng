import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/local_store.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/product.dart';
import '../../domain/services/invoice_number_service.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

class ProfileSaved extends AppEvent {
  final BusinessProfile profile;
  const ProfileSaved(this.profile);
  @override
  List<Object?> get props => [profile];
}

class CustomerSaved extends AppEvent {
  final Customer customer;
  const CustomerSaved(this.customer);
  @override
  List<Object?> get props => [customer];
}

class CustomerDeleted extends AppEvent {
  final String id;
  const CustomerDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class ProductSaved extends AppEvent {
  final Product product;
  const ProductSaved(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends AppEvent {
  final String id;
  const ProductDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class InvoiceCreated extends AppEvent {
  final Invoice invoice;
  const InvoiceCreated(this.invoice);
  @override
  List<Object?> get props => [invoice];
}

class InvoiceStatusUpdated extends AppEvent {
  final String id;
  final InvoiceStatus status;
  const InvoiceStatusUpdated(this.id, this.status);
  @override
  List<Object?> get props => [id, status];
}

class InvoiceDeleted extends AppEvent {
  final String id;
  const InvoiceDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class AppState extends Equatable {
  final bool loading;
  final BusinessProfile profile;
  final List<Customer> customers;
  final List<Product> products;
  final List<Invoice> invoices;

  const AppState({
    this.loading = true,
    this.profile = BusinessProfile.empty,
    this.customers = const [],
    this.products = const [],
    this.invoices = const [],
  });

  double get totalRevenue =>
      invoices.where((i) => i.status == InvoiceStatus.paid).fold(0.0, (s, i) => s + i.grandTotal);
  double get totalPending =>
      invoices.where((i) => i.status == InvoiceStatus.sent).fold(0.0, (s, i) => s + i.grandTotal);
  double get totalVatCollected => invoices.fold(0.0, (s, i) => s + i.totalVat);

  AppState copyWith({
    bool? loading,
    BusinessProfile? profile,
    List<Customer>? customers,
    List<Product>? products,
    List<Invoice>? invoices,
  }) {
    return AppState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      customers: customers ?? this.customers,
      products: products ?? this.products,
      invoices: invoices ?? this.invoices,
    );
  }

  @override
  List<Object?> get props => [loading, profile, customers, products, invoices];
}

class AppBloc extends Bloc<AppEvent, AppState> {
  final LocalStore store;
  final InvoiceNumberService numberService;

  AppBloc({LocalStore? store, InvoiceNumberService? numberService})
      : store = store ?? LocalStore(),
        numberService = numberService ?? const InvoiceNumberService(),
        super(const AppState()) {
    on<AppStarted>(_onStarted);
    on<ProfileSaved>(_onProfileSaved);
    on<CustomerSaved>(_onCustomerSaved);
    on<CustomerDeleted>(_onCustomerDeleted);
    on<ProductSaved>(_onProductSaved);
    on<ProductDeleted>(_onProductDeleted);
    on<InvoiceCreated>(_onInvoiceCreated);
    on<InvoiceStatusUpdated>(_onInvoiceStatusUpdated);
    on<InvoiceDeleted>(_onInvoiceDeleted);
  }

  Future<void> _onStarted(AppStarted event, Emitter<AppState> emit) async {
    await store.init();
    emit(AppState(
      loading: false,
      profile: store.loadProfile() ?? BusinessProfile.empty,
      customers: store.loadCustomers(),
      products: store.loadProducts(),
      invoices: store.loadInvoices(),
    ));
  }

  Future<void> _onProfileSaved(ProfileSaved event, Emitter<AppState> emit) async {
    await store.saveProfile(event.profile);
    emit(state.copyWith(profile: event.profile));
  }

  Future<void> _onCustomerSaved(CustomerSaved event, Emitter<AppState> emit) async {
    await store.saveCustomer(event.customer);
    final list = [...state.customers];
    final idx = list.indexWhere((c) => c.id == event.customer.id);
    if (idx >= 0) {
      list[idx] = event.customer;
    } else {
      list.add(event.customer);
    }
    emit(state.copyWith(customers: list));
  }

  Future<void> _onCustomerDeleted(CustomerDeleted event, Emitter<AppState> emit) async {
    await store.deleteCustomer(event.id);
    emit(state.copyWith(customers: state.customers.where((c) => c.id != event.id).toList()));
  }

  Future<void> _onProductSaved(ProductSaved event, Emitter<AppState> emit) async {
    await store.saveProduct(event.product);
    final list = [...state.products];
    final idx = list.indexWhere((p) => p.id == event.product.id);
    if (idx >= 0) {
      list[idx] = event.product;
    } else {
      list.add(event.product);
    }
    emit(state.copyWith(products: list));
  }

  Future<void> _onProductDeleted(ProductDeleted event, Emitter<AppState> emit) async {
    await store.deleteProduct(event.id);
    emit(state.copyWith(products: state.products.where((p) => p.id != event.id).toList()));
  }

  Future<void> _onInvoiceCreated(InvoiceCreated event, Emitter<AppState> emit) async {
    await store.saveInvoice(event.invoice);
    emit(state.copyWith(invoices: [event.invoice, ...state.invoices]));
  }

  Future<void> _onInvoiceStatusUpdated(InvoiceStatusUpdated event, Emitter<AppState> emit) async {
    final idx = state.invoices.indexWhere((i) => i.id == event.id);
    if (idx == -1) return;
    final updated = state.invoices[idx].copyWith(status: event.status);
    await store.saveInvoice(updated);
    final list = [...state.invoices];
    list[idx] = updated;
    emit(state.copyWith(invoices: list));
  }

  Future<void> _onInvoiceDeleted(InvoiceDeleted event, Emitter<AppState> emit) async {
    await store.deleteInvoice(event.id);
    emit(state.copyWith(invoices: state.invoices.where((i) => i.id != event.id).toList()));
  }

  /// Suggests the next sequential invoice number for the given year based on
  /// invoices already known to this bloc.
  String suggestNextInvoiceNumber({int? year}) {
    final y = year ?? DateTime.now().year;
    return numberService.nextNumber(
      existingNumbers: state.invoices.map((i) => i.invoiceNumber).toList(),
      year: y,
      prefix: state.profile.invoicePrefix.isEmpty ? 'INV' : state.profile.invoicePrefix,
    );
  }
}
