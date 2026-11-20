import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

import '../../../support/compare_test_support.dart';

// Claves crudas como las guarda el comparador, y su nombre legible.
const String _rawKey = 'Corolla LE 4dr Sedan (M6)';
const String _readable = 'Manual · 4 cil · 2.0 L';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('CompareVersionLabelBuilder', () {
    Future<void> pump(
      WidgetTester tester,
      CompareVersionLabeler labeler,
      CompareSlotEntity slot,
    ) => tester.pumpWidget(
      MaterialApp(
        home: CompareVersionLabelBuilder(
          slot: slot,
          labeler: labeler,
          builder: (context, label) => Text(label),
        ),
      ),
    );

    testWidgets('sin versión elegida muestra "Predeterminada" al instante', (
      tester,
    ) async {
      await pump(tester, FakeCompareVersionLabeler(), compareSlot());
      expect(find.text(AppTexts.compareVersionDefaultLabel), findsOneWidget);
    });

    testWidgets('mientras resuelve muestra "—" y luego la etiqueta', (
      tester,
    ) async {
      final labeler = _PendingLabeler();
      await pump(tester, labeler, compareSlot(versionKey: _rawKey));
      expect(find.text(AppTexts.missingValueLabel), findsOneWidget);
      labeler.completer.complete(_readable);
      await tester.pump();
      expect(find.text(_readable), findsOneWidget);
    });
  });

  group('hoja de versiones', () {
    testWidgets('marca la versión predeterminada del modelo', (tester) async {
      final source = FakeCompareVersionsSource()
        ..versions['Corolla'] = const [
          CompareVersionOptionEntity(key: 'A', label: 'Versión A'),
          CompareVersionOptionEntity(
            key: 'B',
            label: 'Versión B',
            isDefault: true,
          ),
        ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompareVersionSheetWidget(
              slot: compareSlot(model: 'Corolla'),
              source: source,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // La fila fija "Predeterminada" y la opción marcada por la regla de Detalle.
      expect(find.text(AppTexts.compareVersionDefaultLabel), findsNWidgets(2));
      final marked = find.descendant(
        of: find
            .ancestor(of: find.text('Versión B'), matching: find.byType(Column))
            .first,
        matching: find.text(AppTexts.compareVersionDefaultLabel),
      );
      expect(marked, findsOneWidget);
    });
  });
}

class _PendingLabeler implements CompareVersionLabeler {
  final Completer<String?> completer = Completer<String?>();

  @override
  Future<String?> labelOf(CompareSlotEntity slot) => completer.future;
}
