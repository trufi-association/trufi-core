import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:trufi_core_transport_list/l10n/transport_list_localizations.dart';
import 'package:trufi_core_transport_list/src/widgets/operator_qr_dialog.dart';

void main() {
  testWidgets('operator QR dialog renders the code and the link', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates:
            TransportListLocalizations.localizationsDelegates,
        supportedLocales: TransportListLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showOperatorQrDialog(
                  context,
                  operatorName: 'Sindicato Pucara Grande',
                  link:
                      'trufiapp://routes?operator=Sindicato%20Pucara%20Grande',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Sindicato Pucara Grande'), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(
      find.text('trufiapp://routes?operator=Sindicato%20Pucara%20Grande'),
      findsOneWidget,
    );
  });
}
