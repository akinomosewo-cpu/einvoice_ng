import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice.dart';

abstract class AppEvent extends Equatable { const AppEvent(); @override List<Object?> get props => []; }
class AppStarted extends AppEvent { const AppStarted(); }
class InvoiceCreated extends AppEvent {
  final Invoice invoice;
  const InvoiceCreated(this.invoice);
  @override List<Object?> get props => [invoice];
}
class InvoiceStatusUpdated extends AppEvent {
  final String id; final InvoiceStatus status;
  const InvoiceStatusUpdated(this.id, this.status);
  @override List<Object?> get props => [id, status];
}
class InvoiceDeleted extends AppEvent {
  final String id; const InvoiceDeleted(this.id);
  @override List<Object?> get props => [id];
}

abstract class AppState extends Equatable { const AppState(); @override List<Object?> get props => []; }
class AppInitial extends AppState { const AppInitial(); }
class AppLoaded extends AppState {
  final List<Invoice> invoices;
  const AppLoaded(this.invoices);
  double get totalRevenue => invoices.where((i) => i.status == InvoiceStatus.paid).fold(0.0, (s, i) => s + i.grandTotal);
  double get totalPending => invoices.where((i) => i.status == InvoiceStatus.sent).fold(0.0, (s, i) => s + i.grandTotal);
  @override List<Object?> get props => [invoices];
}

class AppBloc extends Bloc<AppEvent, AppState> {
  final _uuid = const Uuid();
  AppBloc() : super(const AppInitial()) {
    on<AppStarted>((e, emit) => emit(const AppLoaded([])));
    on<InvoiceCreated>((e, emit) {
      if (state is AppLoaded) emit(AppLoaded([...(state as AppLoaded).invoices, e.invoice]));
    });
    on<InvoiceDeleted>((e, emit) {
      if (state is AppLoaded) emit(AppLoaded((state as AppLoaded).invoices.where((i) => i.id != e.id).toList()));
    });
    on<InvoiceStatusUpdated>((e, emit) {
      if (state is AppLoaded) {
        emit(AppLoaded((state as AppLoaded).invoices.map((i) => i.id == e.id
          ? Invoice(id: i.id, invoiceNumber: i.invoiceNumber, buyerName: i.buyerName, buyerTin: i.buyerTin,
              buyerAddress: i.buyerAddress, sellerName: i.sellerName, sellerTin: i.sellerTin,
              sellerAddress: i.sellerAddress, items: i.items, issueDate: i.issueDate,
              dueDate: i.dueDate, status: e.status, nrsValidationCode: i.nrsValidationCode)
          : i).toList()));
      }
    });
  }
}
