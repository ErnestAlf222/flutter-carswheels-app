import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/detail_test_support.dart';
import '../../../support/mx_detail_test_support.dart';

void main() {
  setUpAll(disableFontFetching);

  Widget host(Widget child) => detailHost(SingleChildScrollView(child: child));

  group('tarjeta de cifras de México', () {
    testWidgets('con tres cifras de km/l las muestra todas', (tester) async {
      await tester.pumpWidget(
        host(DetailMxFiguresCardWidget(detail: mxDetail('COROLLA'))),
      );
      expect(find.byType(DetailFiguresCardWidget), findsOneWidget);
      expect(find.text(AppTexts.detailCityCaption), findsOneWidget);
      expect(find.text(AppTexts.detailHighwayCaption), findsOneWidget);
      expect(find.text(AppTexts.detailCombinedCaption), findsOneWidget);
    });

    testWidgets('con una sola cifra la tarjeta no aparece', (tester) async {
      final detail = testDetail(cityKmPerLiter: 12.3, combinedKmPerLiter: null);
      await tester.pumpWidget(host(DetailMxFiguresCardWidget(detail: detail)));
      expect(find.byType(DetailFiguresCardWidget), findsNothing);
    });

    testWidgets('sin ninguna cifra la tarjeta no aparece', (tester) async {
      final detail = testDetail(combinedKmPerLiter: null);
      await tester.pumpWidget(host(DetailMxFiguresCardWidget(detail: detail)));
      expect(find.byType(DetailFiguresCardWidget), findsNothing);
    });
  });

  group('filas de México', () {
    testWidgets('solo aparecen las filas con dato limpio', (tester) async {
      await tester.pumpWidget(
        host(DetailMxInfoRowsWidget(detail: mxDetail('AVATR 11 AWD'))),
      );
      // Un eléctrico con ceros de relleno: sin cilindros, cilindrada ni transmisión.
      expect(find.text(AppTexts.detailFuelRowLabel), findsOneWidget);
      expect(find.text(AppTexts.detailCylindersRowLabel), findsNothing);
      expect(find.text(AppTexts.detailDisplacementRowLabel), findsNothing);
      expect(find.text(AppTexts.detailTransmissionRowLabel), findsNothing);
      expect(find.text(AppTexts.detailCompressionRowLabel), findsNothing);
      expect(find.text(AppTexts.noDataLabel), findsNothing);
    });

    testWidgets('la compresión con basura no tiene fila', (tester) async {
      final detail = const MxVehicleDetailBuilder().build(
        dieselVehicle(1),
        2025,
      );
      await tester.pumpWidget(host(DetailMxInfoRowsWidget(detail: detail)));
      expect(find.text(AppTexts.detailCompressionRowLabel), findsNothing);
      expect(find.text('181 hp @ 3500 rpm'), findsOneWidget);
      expect(find.text('2,442 cm³ (2.4 L)'), findsOneWidget);
    });

    testWidgets('transmisión no confirmada se muestra tal cual', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          DetailMxInfoRowsWidget(detail: mxDetail('KICKS PLAY E-POWER E-REV')),
        ),
      );
      expect(find.text('Rg'), findsOneWidget);
    });
  });

  group('hoja de versiones de México', () {
    testWidgets('lista cada etiqueta, km/l a la derecha y motor en EV', (
      tester,
    ) async {
      final versions = [
        testVersion(mxDetail('COROLLA'), label: 'COROLLA · CVT'),
        testVersion(mxDetail('LYRIQ F'), label: 'LYRIQ F'),
        testVersion(
          mxDetail('OUTLANDER PHEV SE PLUS'),
          label: 'OUTLANDER PHEV',
        ),
      ];
      await tester.pumpWidget(
        detailHost(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showVersionSheet(
                context,
                versions: versions,
                selectedIndex: 0,
                onSelected: (_) {},
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('COROLLA · CVT'), findsOneWidget);
      expect(find.text('19.1'), findsOneWidget);
      // Sin subtítulo con el nombre original: la etiqueta ya es el nombre.
      expect(find.text('Corolla'), findsNothing);
      expect(find.text(AppTexts.electricLabel), findsOneWidget);
      expect(find.text(AppTexts.pluginHybridLabel), findsOneWidget);
      // EV y enchufable no muestran km/l.
      expect(find.text(AppTexts.kmPerLiterUnit), findsOneWidget);
    });
  });

  test('el selector por defecto elige la primera si ninguna tiene km/l', () {
    final index = const DefaultVersionSelector().selectIndex([
      mxDetail('LYRIQ F'),
      mxDetail('OUTLANDER PHEV SE PLUS'),
    ]);
    expect(index, 0);
  });

  test('la atribución es la frase exacta de CONUEE', () {
    expect(
      AppTexts.conueeAttribution,
      'Fuente: CONUEE, Catálogo de rendimiento de combustible en vehículos '
      'ligeros de venta en México, vía datos.gob.mx (CC BY 4.0)',
    );
  });
}
