import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

import '../../../support/compare_test_support.dart';

CompareTableState _state(
  List<CompareSlotEntity> slots,
  List<CompareVehicleDetailEntity?> details,
) => CompareTableState({
  for (final (index, slot) in slots.indexed)
    slot.identity: details[index] == null
        ? const CompareColumnLoading()
        : CompareColumnLoaded(details[index]!),
});

Widget _host(
  List<CompareSlotEntity> slots,
  CompareTableState table, {
  required bool still,
  double width = 360,
  double textScale = 1.0,
}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      size: Size(width, 900),
      disableAnimations: still,
      textScaler: TextScaler.linear(textScale),
    ),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: SizedBox(
        width: width,
        child: CompareTableWidget(slots: slots, table: table, onRetry: (_) {}),
      ),
    ),
  ),
);

Finder get _fades => find.descendant(
  of: find.byType(CompareTableWidget),
  matching: find.byType(FadeTransition),
);

void main() {
  final slots = [compareSlot(model: 'Corolla'), compareSlot(model: 'Camry')];
  const slow = CompareVehicleDetailEntity(combinedKmPerLiter: 12.0);
  const fast = CompareVehicleDetailEntity(combinedKmPerLiter: 18.0);
  const other = CompareVehicleDetailEntity(combinedKmPerLiter: 15.0);

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    'con animaciones el valor nuevo entra con fundido y el viejo sale',
    (tester) async {
      await tester.pumpWidget(
        _host(slots, _state(slots, [slow, fast]), still: false),
      );
      await tester.pumpAndSettle();
      expect(find.text('12.0'), findsOneWidget);
      await tester.pumpWidget(
        _host(slots, _state(slots, [other, fast]), still: false),
      );
      await tester.pump(AppMotion.fast ~/ 2);
      // A mitad conviven los dos valores.
      expect(find.text('12.0'), findsOneWidget);
      expect(find.text('15.0'), findsOneWidget);
      await tester.pump(AppMotion.medium);
      await tester.pumpAndSettle();
      expect(find.text('12.0'), findsNothing);
      expect(find.text('15.0'), findsOneWidget);
    },
  );

  testWidgets('con disableAnimations el cambio es inmediato, sin convivir', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(slots, _state(slots, [slow, fast]), still: true),
    );
    await tester.pumpWidget(
      _host(slots, _state(slots, [other, fast]), still: true),
    );
    await tester.pump();
    expect(find.text('12.0'), findsNothing);
    expect(find.text('15.0'), findsOneWidget);
  });

  testWidgets('la fila no salta de alto al cambiar un valor', (tester) async {
    await tester.pumpWidget(
      _host(slots, _state(slots, [slow, fast]), still: false),
    );
    await tester.pumpAndSettle();
    final before = tester.getSize(find.byType(CompareTableWidget)).height;
    await tester.pumpWidget(
      _host(slots, _state(slots, [other, fast]), still: false),
    );
    await tester.pump(AppMotion.fast ~/ 2);
    expect(tester.getSize(find.byType(CompareTableWidget)).height, before);
  });

  testWidgets('una columna se llena con fundido cuando llegan sus datos', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(slots, _state(slots, [slow, null]), still: false),
    );
    await tester.pump(AppMotion.slow);
    expect(find.text('12.0'), findsOneWidget);
    expect(find.text('18.0'), findsNothing);
    await tester.pumpWidget(
      _host(slots, _state(slots, [slow, fast]), still: false),
    );
    await tester.pump(AppMotion.fast ~/ 2);
    expect(_fades, findsWidgets);
    await tester.pump(AppMotion.slow);
    expect(find.text('18.0'), findsOneWidget);
  });

  testWidgets('la primera carga arma las filas en cascada corta', (
    tester,
  ) async {
    const full = CompareVehicleDetailEntity(
      combinedKmPerLiter: 12.0,
      cityKmPerLiter: 10.0,
      highwayKmPerLiter: 14.0,
      co2GramsPerKilometer: 150,
    );
    await tester.pumpWidget(
      _host(slots, _state(slots, [full, full]), still: false),
    );
    await tester.pump(const Duration(milliseconds: 30));
    // Las primeras filas ya asoman; las siguientes llegan con su desfase.
    final opacities = tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(CompareTableWidget),
            matching: find.byType(Opacity),
          ),
        )
        .map((widget) => widget.opacity)
        .toList();
    expect(opacities.any((value) => value < 1.0), isTrue);
    await tester.pumpAndSettle();
    final settled = tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byType(CompareTableWidget),
            matching: find.byType(Opacity),
          ),
        )
        .map((widget) => widget.opacity);
    expect(settled.every((value) => value == 1.0), isTrue);
  });

  testWidgets('sin desbordes a 360 dp y texto 1.3', (tester) async {
    await tester.pumpWidget(
      _host(slots, _state(slots, [slow, fast]), still: false, textScale: 1.3),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
