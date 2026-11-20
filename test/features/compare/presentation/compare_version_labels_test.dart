import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

import '../../../support/compare_test_support.dart';

final CompareSlotVisuals _visuals = CompareSlotVisuals(
  photoBuilder: (context, slot) => const ColoredBox(color: Colors.grey),
  logoBuilder: (context, slot, size) => SizedBox(width: size, height: size),
);

// Claves crudas como las guarda el comparador, y su nombre legible.
const String _rawKey = 'Corolla LE 4dr Sedan (M6)';
const String _readable = 'Manual · 4 cil · 2.0 L';

Future<void> _pumpFullSheet(
  WidgetTester tester, {
  required List<CompareSlotEntity> current,
  required FakeCompareVersionLabeler labeler,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CompareFullSheetWidget(
            current: current,
            incoming: compareSlot(model: 'Civic', brand: 'Honda'),
            visuals: _visuals,
            versionLabeler: labeler,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('hoja de comparador lleno', () {
    testWidgets('cada fila muestra la versión legible, no la clave guardada', (
      tester,
    ) async {
      final labeler = FakeCompareVersionLabeler({_rawKey: _readable});
      await _pumpFullSheet(
        tester,
        current: [
          compareSlot(model: 'Corolla', versionKey: _rawKey),
          compareSlot(model: 'Camry'),
        ],
        labeler: labeler,
      );
      expect(find.text(_readable), findsOneWidget);
      expect(find.text(_rawKey), findsNothing);
      // Sin versión elegida es la predeterminada.
      expect(find.text(AppTexts.compareVersionDefaultLabel), findsOneWidget);
    });

    testWidgets('sin etiqueta resuelta queda la clave, nunca vacío', (
      tester,
    ) async {
      final labeler = FakeCompareVersionLabeler()..failing.add(_rawKey);
      await _pumpFullSheet(
        tester,
        current: [compareSlot(model: 'Corolla', versionKey: _rawKey)],
        labeler: labeler,
      );
      expect(find.text(_rawKey), findsOneWidget);
    });
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
