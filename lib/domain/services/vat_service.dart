import '../entities/invoice.dart';

/// Pure VAT/invoice-total calculation logic, kept separate from persistence
/// and UI so it can be unit tested in isolation.
class VatService {
  const VatService();

  /// VAT rate as a fraction (e.g. 0.075 for 7.5%) for the given [rate].
  double rateFraction(VatRate rate) => vatRateToPercent(rate);

  /// Net (pre-VAT) total for a single line.
  double lineSubtotal(double quantity, double unitPrice) => quantity * unitPrice;

  /// VAT amount for a single line.
  double lineVat(double quantity, double unitPrice, VatRate rate) =>
      lineSubtotal(quantity, unitPrice) * rateFraction(rate);

  /// Gross (VAT-inclusive) total for a single line.
  double lineTotal(double quantity, double unitPrice, VatRate rate) =>
      lineSubtotal(quantity, unitPrice) + lineVat(quantity, unitPrice, rate);

  /// Sum of net subtotals across all [items].
  double subtotal(List<InvoiceItem> items) =>
      items.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// Sum of VAT across all [items].
  double totalVat(List<InvoiceItem> items) =>
      items.fold(0.0, (sum, item) => sum + item.vatAmount);

  /// Grand (VAT-inclusive) total across all [items].
  double grandTotal(List<InvoiceItem> items) => subtotal(items) + totalVat(items);
}
