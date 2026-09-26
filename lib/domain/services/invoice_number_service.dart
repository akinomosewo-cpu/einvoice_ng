/// Generates sequential, government-format-friendly invoice numbers of the
/// shape `PREFIX-YEAR-0001`, resetting the sequence each calendar year.
///
/// Kept pure (no I/O) so numbering logic can be unit tested without a
/// storage layer. The bloc/repository is responsible for persisting the
/// resulting sequence.
class InvoiceNumberService {
  const InvoiceNumberService();

  static final RegExp _pattern = RegExp(r'^([A-Za-z]+)-(\d{4})-(\d+)$');

  /// Returns the next invoice number for [year] given the [existingNumbers]
  /// already issued (any order, any year), prefixed with [prefix].
  String nextNumber({
    required List<String> existingNumbers,
    required int year,
    String prefix = 'INV',
  }) {
    final nextSeq = nextSequence(existingNumbers: existingNumbers, year: year, prefix: prefix);
    return format(prefix: prefix, year: year, sequence: nextSeq);
  }

  /// Returns the next sequence integer (1-based) for [year], looking only at
  /// numbers matching [prefix] and [year] among [existingNumbers].
  int nextSequence({
    required List<String> existingNumbers,
    required int year,
    String prefix = 'INV',
  }) {
    var maxSeq = 0;
    for (final number in existingNumbers) {
      final match = _pattern.firstMatch(number.trim());
      if (match == null) continue;
      if (match.group(1)?.toUpperCase() != prefix.toUpperCase()) continue;
      if (int.tryParse(match.group(2) ?? '') != year) continue;
      final seq = int.tryParse(match.group(3) ?? '') ?? 0;
      if (seq > maxSeq) maxSeq = seq;
    }
    return maxSeq + 1;
  }

  String format({required String prefix, required int year, required int sequence}) {
    return '${prefix.toUpperCase()}-$year-${sequence.toString().padLeft(4, '0')}';
  }

  /// True if [number] already exists in [existingNumbers] (case-insensitive).
  bool isDuplicate(String number, List<String> existingNumbers) =>
      existingNumbers.any((n) => n.toUpperCase() == number.toUpperCase());
}
