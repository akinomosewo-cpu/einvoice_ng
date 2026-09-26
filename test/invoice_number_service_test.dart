import 'package:flutter_test/flutter_test.dart';
import 'package:einvoice_ng/domain/services/invoice_number_service.dart';

void main() {
  const service = InvoiceNumberService();

  group('InvoiceNumberService', () {
    test('starts at 0001 when there are no existing invoices', () {
      final number = service.nextNumber(existingNumbers: [], year: 2027, prefix: 'INV');
      expect(number, 'INV-2027-0001');
    });

    test('increments sequentially based on existing numbers for the same year', () {
      final number = service.nextNumber(
        existingNumbers: ['INV-2027-0001', 'INV-2027-0002', 'INV-2027-0003'],
        year: 2027,
        prefix: 'INV',
      );
      expect(number, 'INV-2027-0004');
    });

    test('resets the sequence for a new year', () {
      final number = service.nextNumber(
        existingNumbers: ['INV-2026-0050'],
        year: 2027,
        prefix: 'INV',
      );
      expect(number, 'INV-2027-0001');
    });

    test('ignores numbers with a different prefix', () {
      final number = service.nextNumber(
        existingNumbers: ['OTHER-2027-0099'],
        year: 2027,
        prefix: 'INV',
      );
      expect(number, 'INV-2027-0001');
    });

    test('ignores malformed numbers', () {
      final number = service.nextNumber(
        existingNumbers: ['not-a-number', 'INV-2027', 'INV-2027-0002'],
        year: 2027,
        prefix: 'INV',
      );
      expect(number, 'INV-2027-0003');
    });

    test('is case-insensitive on prefix matching', () {
      final number = service.nextNumber(
        existingNumbers: ['inv-2027-0005'],
        year: 2027,
        prefix: 'INV',
      );
      expect(number, 'INV-2027-0006');
    });

    test('pads sequence to 4 digits', () {
      expect(service.format(prefix: 'INV', year: 2027, sequence: 7), 'INV-2027-0007');
      expect(service.format(prefix: 'INV', year: 2027, sequence: 12345), 'INV-2027-12345');
    });

    test('isDuplicate detects an existing number case-insensitively', () {
      expect(service.isDuplicate('inv-2027-0001', ['INV-2027-0001']), isTrue);
      expect(service.isDuplicate('INV-2027-0002', ['INV-2027-0001']), isFalse);
    });

    test('takes the max sequence, not just the last item, regardless of order', () {
      final number = service.nextNumber(
        existingNumbers: ['INV-2027-0003', 'INV-2027-0001', 'INV-2027-0002'],
        year: 2027,
        prefix: 'INV',
      );
      expect(number, 'INV-2027-0004');
    });
  });
}
