import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trufi_core_fares/trufi_core_fares.dart';

/// trufi-core#1002: notes resolve the way titles and labels already do —
/// the builder wins when present, the plain string is the fallback and
/// `null` keeps meaning "no notes block".
Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    Builder(
      builder: (context) {
        captured = context;
        return const SizedBox.shrink();
      },
    ),
  );
  return captured;
}

const _primary = FareCategory(label: 'General', price: '3.00');

void main() {
  group('FareInfo.localizedNotes', () {
    testWidgets('the builder wins over the plain notes', (tester) async {
      final context = await _pumpContext(tester);
      final fare = FareInfo(
        title: 'Urban',
        icon: Icons.directions_bus_rounded,
        primary: _primary,
        notes: 'Plain notes',
        notesBuilder: (_) => 'Built notes',
      );

      expect(fare.localizedNotes(context), 'Built notes');
    });

    testWidgets('falls back to the plain notes without a builder', (
      tester,
    ) async {
      final context = await _pumpContext(tester);
      const fare = FareInfo(
        title: 'Urban',
        icon: Icons.directions_bus_rounded,
        primary: _primary,
        notes: 'Plain notes',
      );

      expect(fare.localizedNotes(context), 'Plain notes');
    });

    testWidgets('is null when neither is set', (tester) async {
      final context = await _pumpContext(tester);
      const fare = FareInfo(
        title: 'Urban',
        icon: Icons.directions_bus_rounded,
        primary: _primary,
      );

      expect(fare.localizedNotes(context), isNull);
    });
  });

  group('FaresConfig.localizedAdditionalNotes', () {
    testWidgets('the builder wins over the plain notes', (tester) async {
      final context = await _pumpContext(tester);
      final config = FaresConfig(
        currency: 'Bs.',
        fares: const [],
        additionalNotes: 'Plain tips',
        additionalNotesBuilder: (_) => 'Built tips',
      );

      expect(config.localizedAdditionalNotes(context), 'Built tips');
    });

    testWidgets('falls back to the plain notes without a builder', (
      tester,
    ) async {
      final context = await _pumpContext(tester);
      const config = FaresConfig(
        currency: 'Bs.',
        fares: [],
        additionalNotes: 'Plain tips',
      );

      expect(config.localizedAdditionalNotes(context), 'Plain tips');
    });

    testWidgets('is null when neither is set', (tester) async {
      final context = await _pumpContext(tester);
      const config = FaresConfig(currency: 'Bs.', fares: []);

      expect(config.localizedAdditionalNotes(context), isNull);
    });
  });
}
