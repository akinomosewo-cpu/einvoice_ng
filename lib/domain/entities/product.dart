import 'invoice.dart';

class Product {
  final String id;
  final String name;
  final double unitPrice;
  final VatRate vatRate;

  const Product({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.vatRate = VatRate.sevenpointfive,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unitPrice': unitPrice,
        'vatRate': vatRate.index,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        vatRate: VatRate.values[(json['vatRate'] as int?) ?? VatRate.sevenpointfive.index],
      );
}
