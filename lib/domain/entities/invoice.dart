import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, validated, sent, paid }
enum VatRate { zero, five, sevenpointfive }

class InvoiceItem extends Equatable {
  final String id, description;
  final double quantity, unitPrice;
  final VatRate vatRate;
  double get lineTotal => quantity * unitPrice;
  double get vatAmount => lineTotal * (vatRate == VatRate.zero ? 0 : vatRate == VatRate.five ? 0.05 : 0.075);
  const InvoiceItem({required this.id, required this.description, required this.quantity, required this.unitPrice, required this.vatRate});
  @override List<Object?> get props => [id, description, quantity, unitPrice, vatRate];
}

class Invoice extends Equatable {
  final String id, invoiceNumber, buyerName, buyerTin, buyerAddress;
  final String sellerName, sellerTin, sellerAddress;
  final List<InvoiceItem> items;
  final DateTime issueDate, dueDate;
  final InvoiceStatus status;
  final String? nrsValidationCode;

  double get subtotal => items.fold(0.0, (s, i) => s + i.lineTotal);
  double get totalVat => items.fold(0.0, (s, i) => s + i.vatAmount);
  double get grandTotal => subtotal + totalVat;

  const Invoice({
    required this.id, required this.invoiceNumber, required this.buyerName,
    required this.buyerTin, required this.buyerAddress, required this.sellerName,
    required this.sellerTin, required this.sellerAddress, required this.items,
    required this.issueDate, required this.dueDate, required this.status, this.nrsValidationCode,
  });
  @override List<Object?> get props => [id, invoiceNumber, status];
}
