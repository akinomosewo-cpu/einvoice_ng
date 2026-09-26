import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, validated, sent, paid }
enum VatRate { zero, five, sevenpointfive }

double vatRateToPercent(VatRate rate) {
  switch (rate) {
    case VatRate.zero:
      return 0.0;
    case VatRate.five:
      return 0.05;
    case VatRate.sevenpointfive:
      return 0.075;
  }
}

class InvoiceItem extends Equatable {
  final String id, description;
  final double quantity, unitPrice;
  final VatRate vatRate;

  double get lineTotal => quantity * unitPrice;
  double get vatAmount => lineTotal * vatRateToPercent(vatRate);
  double get lineTotalWithVat => lineTotal + vatAmount;

  const InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.vatRate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'vatRate': vatRate.index,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        id: json['id'] as String,
        description: json['description'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        vatRate: VatRate.values[(json['vatRate'] as int?) ?? VatRate.sevenpointfive.index],
      );

  @override
  List<Object?> get props => [id, description, quantity, unitPrice, vatRate];
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
    required this.id,
    required this.invoiceNumber,
    required this.buyerName,
    required this.buyerTin,
    required this.buyerAddress,
    required this.sellerName,
    required this.sellerTin,
    required this.sellerAddress,
    required this.items,
    required this.issueDate,
    required this.dueDate,
    required this.status,
    this.nrsValidationCode,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? buyerName,
    String? buyerTin,
    String? buyerAddress,
    String? sellerName,
    String? sellerTin,
    String? sellerAddress,
    List<InvoiceItem>? items,
    DateTime? issueDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    String? nrsValidationCode,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      buyerName: buyerName ?? this.buyerName,
      buyerTin: buyerTin ?? this.buyerTin,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      sellerName: sellerName ?? this.sellerName,
      sellerTin: sellerTin ?? this.sellerTin,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      items: items ?? this.items,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      nrsValidationCode: nrsValidationCode ?? this.nrsValidationCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'buyerName': buyerName,
        'buyerTin': buyerTin,
        'buyerAddress': buyerAddress,
        'sellerName': sellerName,
        'sellerTin': sellerTin,
        'sellerAddress': sellerAddress,
        'items': items.map((e) => e.toJson()).toList(),
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'status': status.index,
        'nrsValidationCode': nrsValidationCode,
      };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String? ?? '',
        buyerName: json['buyerName'] as String? ?? '',
        buyerTin: json['buyerTin'] as String? ?? '',
        buyerAddress: json['buyerAddress'] as String? ?? '',
        sellerName: json['sellerName'] as String? ?? '',
        sellerTin: json['sellerTin'] as String? ?? '',
        sellerAddress: json['sellerAddress'] as String? ?? '',
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        issueDate: DateTime.parse(json['issueDate'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        status: InvoiceStatus.values[(json['status'] as int?) ?? 0],
        nrsValidationCode: json['nrsValidationCode'] as String?,
      );

  @override
  List<Object?> get props => [id, invoiceNumber, status, items, buyerName, sellerName];
}
