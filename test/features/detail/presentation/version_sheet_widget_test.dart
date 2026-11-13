import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/detail_test_support.dart';

void main() {
  setUpAll(disableFontFetching);

  final versions = [
    testVersion(testDetail(id: 1), variantName: 'Corolla'),
    testVersion(
      testDetail(id: 2, transmission: 'Manual 6-spd', displacementLiters: 1.8),
      variantName: 'Corolla LE',
    ),
    testVersion(
      testDetail(
        id: 3,
        powertrain: Powertrain.electric,
        combinedKmPerLiter: null,
        transmission: null,
        cylinders: null,
        displacementLiters: null,
      ),
      variantName: 'Corolla EV',
    ),
  ];

  // Abre la hoja desde un botón; devuelve los índices elegidos.
  Future<List<int>> openSheet(
    WidgetTester tester, {
    int selected = 0,
    List<GroupVersionEntity>? items,
  }) async {
    final picked = <int>[];
    await tester.pumpWidget(
      detailHost(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showVersionSheet(
              context,
              versions: items ?? versions,
              selectedIndex: selected,
              onSelected: picked.add,
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return picked;
  }

  testWidgets('muestra el título, el asa y todas las versiones', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.text(AppTexts.versionSheetTitle), findsOneWidget);
    expect(find.byType(VersionSheetWidget), findsOneWidget);
    expect(find.text('Corolla'), findsOneWidget);
    expect(find.text('Corolla LE'), findsOneWidget);
    expect(find.text('Automática CVT 10 vel. · 4 cil · 2.0 L'), findsOneWidget);
    expect(find.text('Manual 6 vel. · 4 cil · 1.8 L'), findsOneWidget);
    // La versión sin descriptor usa el nombre de la variante como título.
    expect(find.text('Corolla EV'), findsNWidgets(2));
  });

  testWidgets('cada fila muestra consumo o la etiqueta de motor', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.text('14.6'), findsNWidgets(2));
    expect(find.text(AppTexts.kmPerLiterUnit), findsNWidgets(2));
    expect(find.text(AppTexts.electricLabel), findsOneWidget);
  });

  testWidgets('marca la versión seleccionada con fondo tint y un check', (
    tester,
  ) async {
    await openSheet(tester, selected: 1);
    expect(find.byIcon(Symbols.check), findsOneWidget);
    final material = tester.widget<Material>(
      find
          .ancestor(
            of: find.text('Corolla LE'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, AppColors.tint);
  });

  testWidgets('elegir una versión llama a onSelected y cierra la hoja', (
    tester,
  ) async {
    final picked = await openSheet(tester);
    await tester.tap(find.text('Corolla LE'));
    await tester.pumpAndSettle();
    expect(picked, [1]);
    expect(find.byType(VersionSheetWidget), findsNothing);
  });

  testWidgets('las filas miden al menos el área táctil mínima', (tester) async {
    await openSheet(tester);
    final row = tester.getSize(
      find
          .ancestor(of: find.text('Corolla'), matching: find.byType(InkWell))
          .first,
    );
    expect(
      row.height,
      greaterThanOrEqualTo(CarouselConfig.arrowTouchTargetSize),
    );
  });

  testWidgets('el alto máximo es el 60% de la pantalla y se desplaza', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final many = [
      for (int i = 0; i < 20; i++)
        testVersion(testDetail(id: i), variantName: 'Variante $i'),
    ];
    await openSheet(tester, items: many);
    final sheet = tester.getSize(find.byType(BottomSheet));
    expect(
      sheet.height,
      lessThanOrEqualTo(600 * UiConfig.detailSheetMaxHeightFraction),
    );
    expect(find.byType(ListView), findsOneWidget);
  });
}
