import 'package:flutter_test/flutter_test.dart';
import 'package:einvoice_ng/domain/entities/invoice.dart';
import 'package:einvoice_ng/domain/services/vat_service.dart';

void main() {
  const service = VatService();

  group('VatService', () {
    test('rateFraction maps enum values to correct fractions', () {
      expect(service.rateFraction(VatRate.zero), 0.0);
      expect(service.rateFraction(VatRate.five), 0.05);
      expect(service.rateFraction(VatRate.sevenpointfive), 0.075);
    });

    test('lineVat computes VAT for a single line at standard 7.5%', () {
      final vat = service.lineVat(2, 1000, VatRate.sevenpointfive);
      expect(vat, closeTo(150.0, 0.001)); // 2 * 1000 * 0.075
    });

    test('lineTotal is subtotal plus VAT', () {
      final total = service.lineTotal(3, 500, VatRate.five);
      // subtotal = 1500, vat = 75, total = 1575
      expect(total, closeTo(1575.0, 0.001));
    });

    test('zero-rated items add no VAT', () {
      expect(service.lineVat(10, 200, VatRate.zero), 0.0);
      expect(service.lineTotal(10, 200, VatRate.zero), 2000.0);
    });

    test('subtotal, totalVat and grandTotal aggregate across mixed-rate items', () {
      final items = [
        const InvoiceItem(id: '1', description: 'Catering', quantity: 2, unitPrice: 5000, vatRate: VatRate.sevenpointfive),
        const InvoiceItem(id: '2', description: 'Delivery', quantity: 1, unitPrice: 2000, vatRate: VatRate.five),
        const InvoiceItem(id: '3', description: 'Export service', quantity: 1, unitPrice: 1000, vatRate: VatRate.zero),
      ];

      // subtotal = 10000 + 2000 + 1000 = 13000
      expect(service.subtotal(items), closeTo(13000.0, 0.001));
      // vat = 750 + 100 + 0 = 850
      expect(service.totalVat(items), closeTo(850.0, 0.001));
      // grand total = 13850
      expect(service.grandTotal(items), closeTo(13850.0, 0.001));
    });

    test('Invoice entity totals match VatService for the same items', () {
      final items = [
        const InvoiceItem(id: '1', description: 'Logistics run', quantity: 4, unitPrice: 7500, vatRate: VatRate.sevenpointfive),
      ];
      final invoice = Invoice(
        id: 'inv-1',
        invoiceNumber: 'INV-2027-0001',
        buyerName: 'Buyer Co',
        buyerTin: 'TIN123',
        buyerAddress: 'Abuja',
        sellerName: 'Seller Co',
        sellerTin: 'TIN456',
        sellerAddress: 'Lagos',
        items: items,
        issueDate: DateTime(2027, 1, 1),
        dueDate: DateTime(2027, 1, 15),
        status: InvoiceStatus.draft,
      );

      expect(invoice.subtotal, service.subtotal(items));
      expect(invoice.totalVat, service.totalVat(items));
      expect(invoice.grandTotal, service.grandTotal(items));
    });

    test('empty item list produces zero totals', () {
      expect(service.subtotal([]), 0.0);
      expect(service.totalVat([]), 0.0);
      expect(service.grandTotal([]), 0.0);
    });
  });
}
