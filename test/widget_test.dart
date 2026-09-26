import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:einvoice_ng/main.dart';

void main() {
  testWidgets('App launches without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const EInvoiceApp());
    await tester.pump();

    // Storage init (Hive) has no platform channel in the test environment,
    // so the home page stays on its loading state — this just verifies the
    // app boots and renders a MaterialApp without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
