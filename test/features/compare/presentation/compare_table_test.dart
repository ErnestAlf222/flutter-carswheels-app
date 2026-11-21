import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../support/compare_test_support.dart';

final CompareSlotVisuals _visuals = CompareSlotVisuals(
  photoBuilder: (context, slot) => const ColoredBox(color: Colors.grey),
  logoBuilder: (context, slot, size) => SizedBox(width: size, height: size),
);

// Tres vehículos con datos distintos: dos de combustión y un eléctrico.
const CompareVehicleDetailEntity _corolla = CompareVehicleDetailEntity(
  versionLabel: 'Automática · 4 cil · 2.0 L',
  engineKind: CompareEngineKind.combustion,
  combinedKmPerLiter: 14.6,
  cityKmPerLiter: 12.5,
  highwayKmPerLiter: 17.0,
  co2GramsPerKilometer: 151,
  fuelLabel: 'Gasolina regular',
  cylindersLabel: '4 cil',
  transmissionLabel: 'Automática CVT 10 vel.',
  driveLabel: 'Tracción delantera',
  classLabel: 'Compactos',
  annualFuelCostUsd: 1750,
);

const CompareVehicleDetailEntity _camry = CompareVehicleDetailEntity(
  engineKind: CompareEngineKind.hybrid,
  combinedKmPerLiter: 16.2,
  cityKmPerLiter: 12.5,
  highwayKmPerLiter: 15.0,
  co2GramsPerKilometer: 120,
  fuelLabel: 'Gasolina regular',
  cylindersLabel: '4 cil',
  transmissionLabel: 'Automática',
  driveLabel: 'Tracción delantera',
  classLabel: 'Medianos',
  annualFuelCostUsd: 1500,
);

const CompareVehicleDetailEntity _electric = CompareVehicleDetailEntity(
  engineKind: CompareEngineKind.electric,
  co2GramsPerKilometer: 0,
  fuelLabel: 'Electricidad',
  transmissionLabel: 'Automática',
  driveLabel: 'Tracción trasera',
  classLabel: 'Medianos',
  annualFuelCostUsd: 600,
);

class _Page {
  const _Page({
    required this.cubit,
    required this.table,
    required this.store,
    required this.vehicles,
    required this.safety,
    required this.versions,
  });

  final CompareCubit cubit;
  final CompareTableCubit table;
  final InMemoryCompareSelection store;
  final FakeCompareVehicleSource vehicles;
  final FakeCompareSafetySource safety;
  final FakeCompareVersionsSource versions;
}

CompareSlotEntity _corollaSlot({String? versionKey}) =>
    compareSlot(model: 'Corolla', versionKey: versionKey);

List<CompareSlotEntity> _slots(int count) => [
  _corollaSlot(),
  compareSlot(model: 'Camry'),
  compareSlot(model: 'Model 3', brand: 'Tesla'),
].take(count).toList();

Future<_Page> _pump(
  WidgetTester tester, {
  required List<CompareSlotEntity> initial,
  double textScale = 1.0,
  void Function(FakeCompareVehicleSource vehicles)? configure,
  String market = 'us',
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final store = InMemoryCompareSelection();
  await store.write(market, initial);
  final vehicles = FakeCompareVehicleSource()
    ..details['Corolla'] = _corolla
    ..details['Camry'] = _camry
    ..details['Model 3'] = _electric;
  final safety = FakeCompareSafetySource()
    ..stars['Corolla'] = 5
    ..stars['Camry'] = 5
    ..stars['Model 3'] = 4;
  final versions = FakeCompareVersionsSource()
    ..versions['Corolla'] = const [
      CompareVersionOptionEntity(
        key: 'Corolla LE',
        label: 'Automática · 4 cil · 2.0 L',
        caption: 'Corolla LE',
      ),
      CompareVersionOptionEntity(key: 'Corolla SE', label: 'Manual · 4 cil'),
    ];
  configure?.call(vehicles);
  final marketSource = FakeCompareMarketSource(market);
  final cubit = buildCompareCubit(
    selection: store,
    market: marketSource,
    noticeDuration: const Duration(seconds: 30),
  );
  addTearDown(cubit.close);
  final table = buildCompareTableCubit(
    compare: cubit,
    vehicles: vehicles,
    safety: safety,
  );
  addTearDown(table.close);
  await tester.pumpWidget(
    RepositoryProvider<CompareVersionLabeler>.value(
      value: FakeCompareVersionLabeler(),
      child: RepositoryProvider<CompareVersionsSource>.value(
        value: versions,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<CompareCubit>.value(value: cubit),
            BlocProvider<CompareTableCubit>.value(value: table),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: true,
                textScaler: TextScaler.linear(textScale),
              ),
              child: child!,
            ),
            home: ComparePage(
              selectorBuilder: (_) => const SizedBox(),
              visuals: _visuals,
              onOpenPicker: (_) async {},
            ),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
  return _Page(
    cubit: cubit,
    table: table,
    store: store,
    vehicles: vehicles,
    safety: safety,
    versions: versions,
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 4; i++) {
    await tester.pump();
  }
}

Finder get _filledSlots => find.byType(CompareFilledSlotWidget);

// Pastillas de relleno accentTint que envuelven un texto.
Finder _bestPillAround(String text) => find.ancestor(
  of: find.text(text),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).color == AppColors.accentTint,
  ),
);

Future<void> _scrollDown(WidgetTester tester, [double pixels = 600]) async {
  await tester.drag(find.byType(CustomScrollView), Offset(0, -pixels));
  await tester.pump();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('rejilla', () {
    testWidgets('cada valor queda bajo su vehículo, con 3 columnas', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(3));
      for (final (column, text) in [
        (0, '14.6'),
        (1, '16.2'),
        (2, AppTexts.noDataLabel),
      ]) {
        final slot = tester.getRect(_filledSlots.at(column));
        final row = find.ancestor(
          of: find.text(AppTexts.compareRowCombinedConsumption),
          matching: find.byType(Column),
        );
        expect(row, findsWidgets);
        // El texto de cada columna cae dentro del ancho de su espacio.
        final value = find
            .descendant(of: row.first, matching: find.text(text))
            .first;
        final rect = tester.getRect(value);
        expect(rect.left, greaterThanOrEqualTo(slot.left), reason: text);
        expect(rect.right, lessThanOrEqualTo(slot.right), reason: text);
      }
    });

    testWidgets('con 2 vehículos la tercera columna queda vacía', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      final lastSlot = tester.getRect(find.byType(CompareEmptySlotWidget));
      final values = find.text('14.6');
      expect(values, findsOneWidget);
      expect(tester.getRect(values).right, lessThan(lastSlot.left));
      // Solo dos celdas por fila: ninguna "—" por la columna sin vehículo.
      expect(find.text(AppTexts.noDataLabel), findsNothing);
    });

    testWidgets('secciones y filas con etiqueta pequeña arriba', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(3));
      expect(find.text(AppTexts.compareSectionConsumption), findsOneWidget);
      expect(find.text(AppTexts.compareSectionEngine), findsOneWidget);
      expect(find.text(AppTexts.compareRowCombinedConsumption), findsOneWidget);
      final label = tester.getRect(
        find.text(AppTexts.compareRowCombinedConsumption),
      );
      final value = tester.getRect(find.text('14.6'));
      expect(label.bottom, lessThanOrEqualTo(value.top));
      expect(find.text(AppTexts.compareTableSupport), findsOneWidget);
    });

    testWidgets('las filas sin dato en nadie no aparecen', (tester) async {
      await _pump(
        tester,
        initial: _slots(2),
        configure: (vehicles) => vehicles
          ..details['Corolla'] = const CompareVehicleDetailEntity(
            fuelLabel: 'Gasolina',
          )
          ..details['Camry'] = const CompareVehicleDetailEntity(
            fuelLabel: 'Diésel',
          ),
      );
      expect(find.text(AppTexts.detailFuelRowLabel), findsOneWidget);
      expect(find.text(AppTexts.compareRowCombinedConsumption), findsNothing);
      expect(find.text(AppTexts.compareSectionConsumption), findsNothing);
    });

    testWidgets('un eléctrico muestra "—" en km/l y la fila sigue', (
      tester,
    ) async {
      await _pump(tester, initial: [_corollaSlot(), _slots(3)[2]]);
      await _scrollDown(tester, 100);
      expect(find.text(AppTexts.compareRowCombinedConsumption), findsOneWidget);
      expect(find.text(AppTexts.noDataLabel), findsWidgets);
      expect(find.text(AppTexts.electricLabel), findsOneWidget);
    });
  });

  group('mejor valor', () {
    testWidgets('se resalta el mejor consumo, no el otro', (tester) async {
      await _pump(tester, initial: _slots(2));
      expect(_bestPillAround('16.2'), findsOneWidget);
      expect(_bestPillAround('14.6'), findsNothing);
    });

    testWidgets('con empate se resaltan todos los empatados', (tester) async {
      await _pump(tester, initial: _slots(2));
      // Ciudad: 12.5 en ambos y no todos iguales no aplica (son iguales).
      expect(_bestPillAround('12.5'), findsNothing);
      // CO₂: gana el menor.
      expect(_bestPillAround(AppTexts.gramsPerKilometerFigure(120)), findsOne);
    });

    testWidgets('las filas sin criterio no se resaltan', (tester) async {
      await _pump(tester, initial: _slots(2));
      await _scrollDown(tester, 300);
      expect(_bestPillAround('Compactos'), findsNothing);
      expect(_bestPillAround('Medianos'), findsNothing);
      expect(_bestPillAround('Gasolina regular'), findsNothing);
      expect(_bestPillAround('4 cil'), findsNothing);
    });

    testWidgets('el costo menor y las estrellas mayores se resaltan', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(3));
      await _scrollDown(tester, 2000);
      expect(_bestPillAround(r'$600'), findsOneWidget);
      expect(_bestPillAround(r'$1,750'), findsNothing);
      // Estrellas: 5, 5 y 4; ganan los dos de 5.
      expect(_bestPillAround(AppTexts.compareStarsValue(5)), findsNWidgets(2));
      expect(_bestPillAround(AppTexts.compareStarsValue(4)), findsNothing);
    });

    testWidgets('lleva el relleno accentTint y texto en negrita', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      final text = tester.widget<Text>(find.text('16.2'));
      expect(text.style!.fontWeight, FontWeight.w700);
      expect(text.style!.color, AppColors.ink);
      expect(
        tester.widget<Text>(find.text('14.6')).style!.fontWeight,
        isNot(FontWeight.w700),
      );
    });
  });

  group('banda fija', () {
    testWidgets('al desplazarse queda pegada arriba con marca y modelo', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(3));
      expect(find.text('Toyota Corolla'), findsOneWidget);
      await _scrollDown(tester, 1200);
      final band = find.text('Toyota Corolla');
      expect(band, findsOneWidget);
      expect(tester.getRect(band).top, lessThan(40));
      expect(find.text('Tesla Model 3'), findsOneWidget);
      // Los espacios grandes con foto ya se fueron con el desplazamiento.
      expect(_filledSlots, findsNothing);
    });
  });

  group('versión por vehículo', () {
    testWidgets('sin versión elegida dice "Versión predeterminada"', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      expect(find.text(AppTexts.compareVersionDefaultLabel), findsNWidgets(2));
    });

    testWidgets('con versión elegida muestra su nombre legible', (
      tester,
    ) async {
      await _pump(
        tester,
        initial: [
          _corollaSlot(versionKey: 'Corolla LE'),
          compareSlot(model: 'Camry'),
        ],
      );
      expect(find.text(_corolla.versionLabel!), findsOneWidget);
      expect(find.text(AppTexts.compareVersionDefaultLabel), findsOneWidget);
    });

    testWidgets('la hoja lista las versiones y elegir una actualiza la tabla', (
      tester,
    ) async {
      final page = await _pump(
        tester,
        initial: _slots(2),
        configure: (vehicles) => vehicles.details['Corolla|Corolla LE'] =
            const CompareVehicleDetailEntity(
              versionLabel: 'Automática · 4 cil · 2.0 L',
              engineKind: CompareEngineKind.combustion,
              combinedKmPerLiter: 20.1,
            ),
      );
      await tester.tap(find.byType(CompareVersionPillWidget).first);
      await _settle(tester);
      expect(find.text(AppTexts.versionSheetTitle), findsOneWidget);
      // Primero la predeterminada y luego cada versión, con su caption.
      expect(find.text(AppTexts.compareVersionDefaultLabel), findsWidgets);
      expect(find.text('Corolla LE'), findsOneWidget);
      expect(find.text('Manual · 4 cil'), findsOneWidget);
      await tester.tap(find.text('Corolla LE'));
      await _settle(tester);
      await _settle(tester);
      // Persistió en la selección y la tabla cambió en el lugar.
      expect((await page.store.read('us')).first.versionKey, 'Corolla LE');
      expect(find.text(AppTexts.versionSheetTitle), findsNothing);
      expect(find.text('20.1'), findsOneWidget);
      expect(find.text('14.6'), findsNothing);
      expect(_bestPillAround('20.1'), findsOneWidget);
      expect(find.text(_corolla.versionLabel!), findsOneWidget);
    });

    testWidgets('elegir "Versión predeterminada" vuelve a la clave nula', (
      tester,
    ) async {
      final page = await _pump(
        tester,
        initial: [
          _corollaSlot(versionKey: 'Corolla LE'),
          compareSlot(model: 'Camry'),
        ],
      );
      await tester.tap(find.byType(CompareVersionPillWidget).first);
      await _settle(tester);
      await tester.tap(find.text(AppTexts.compareVersionDefaultLabel).last);
      await _settle(tester);
      await _settle(tester);
      expect((await page.store.read('us')).first.versionKey, isNull);
    });

    testWidgets('una versión que repetiría otro vehículo no se aplica', (
      tester,
    ) async {
      final page = await _pump(
        tester,
        initial: [
          _corollaSlot(),
          _corollaSlot(versionKey: 'Corolla LE'),
        ],
      );
      await tester.tap(find.byType(CompareVersionPillWidget).first);
      await _settle(tester);
      await tester.tap(find.text('Corolla LE'));
      await _settle(tester);
      expect((await page.store.read('us')).first.versionKey, isNull);
      expect(find.text(AppTexts.compareAlreadyAddedNotice), findsOneWidget);
      page.cubit.dismissNotice();
    });

    testWidgets('si las versiones fallan, la hoja ofrece reintentar', (
      tester,
    ) async {
      final page = await _pump(tester, initial: _slots(2));
      page.versions.failing = true;
      await tester.tap(find.byType(CompareVersionPillWidget).first);
      await _settle(tester);
      expect(find.text(AppTexts.compareColumnLoadFailed), findsOneWidget);
      page.versions.failing = false;
      await tester.tap(find.text(AppTexts.retryButtonLabel));
      await _settle(tester);
      expect(find.text('Corolla LE'), findsOneWidget);
      expect(page.versions.requests, 2);
    });
  });

  group('carga y error por columna', () {
    testWidgets(
      'una columna cargando muestra el loader y las otras no se mueven',
      (tester) async {
        final gate = Completer<void>();
        await _pump(
          tester,
          initial: _slots(2),
          configure: (vehicles) => vehicles.gates['Camry'] = gate,
        );
        expect(find.byType(AppLoader), findsOneWidget);
        // La columna ya cargada muestra sus valores y la otra no tiene celdas.
        expect(find.text('14.6'), findsOneWidget);
        expect(find.text('16.2'), findsNothing);
        // Sin segundo dato no hay mejor valor.
        expect(_bestPillAround('14.6'), findsNothing);
        final before = tester.getTopLeft(find.text('14.6'));
        gate.complete();
        await _settle(tester);
        expect(find.byType(AppLoader), findsNothing);
        expect(find.text('16.2'), findsOneWidget);
        expect(_bestPillAround('16.2'), findsOneWidget);
        // El loader ocupaba su fila: el contenido se acomoda solo una vez.
        expect(tester.getTopLeft(find.text('14.6')).dx, before.dx);
      },
    );

    testWidgets('el error muestra el mensaje y Reintentar, fuera del cálculo', (
      tester,
    ) async {
      final page = await _pump(
        tester,
        initial: _slots(3),
        configure: (vehicles) => vehicles.failing.add('Camry'),
      );
      expect(find.text(AppTexts.compareColumnLoadFailed), findsOneWidget);
      expect(find.text(AppTexts.retryButtonLabel), findsOneWidget);
      // Sus valores no entran al mejor valor: Corolla 14.6 vs eléctrico sin dato.
      expect(_bestPillAround('16.2'), findsNothing);
      expect(_bestPillAround('14.6'), findsNothing);
      page.vehicles.failing.clear();
      await tester.tap(find.text(AppTexts.retryButtonLabel));
      await _settle(tester);
      expect(find.text(AppTexts.compareColumnLoadFailed), findsNothing);
      expect(find.text('16.2'), findsOneWidget);
      expect(_bestPillAround('16.2'), findsOneWidget);
    });

    testWidgets('cada columna pide una sola vez y sin repetir al volver', (
      tester,
    ) async {
      final page = await _pump(tester, initial: _slots(3));
      expect(page.vehicles.requests, hasLength(3));
      // Una nueva selección con el mismo vehículo no repite la petición.
      await page.cubit.remove(_slots(3)[2]);
      await _settle(tester);
      expect(page.vehicles.requests, hasLength(3));
    });
  });

  group('sin desbordes a 360 dp', () {
    for (final count in [2, 3]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets('$count vehículos con texto x$scale', (tester) async {
          await _pump(tester, initial: _slots(count), textScale: scale);
          for (int i = 0; i < 6; i++) {
            expect(tester.takeException(), isNull);
            await _scrollDown(tester, 500);
          }
          expect(tester.takeException(), isNull);
          final width = tester.getSize(find.byType(ComparePage)).width;
          for (final element in find.byType(Text).evaluate()) {
            final rect = tester.getRect(find.byWidget(element.widget));
            expect(rect.right, lessThanOrEqualTo(width + 0.5));
          }
        });
      }
    }
  });

  testWidgets('el cambio de mercado arma la tabla del nuevo mercado', (
    tester,
  ) async {
    final market = FakeCompareMarketSource();
    final store = InMemoryCompareSelection();
    await store.write('us', _slots(2));
    await store.write('mx', [
      compareSlot(model: 'Versa', brand: 'Nissan', marketCode: 'mx'),
      compareSlot(model: 'Aveo', brand: 'Chevrolet', marketCode: 'mx'),
    ]);
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final vehicles = FakeCompareVehicleSource()
      ..details['Corolla'] = _corolla
      ..details['Camry'] = _camry
      ..details['Versa'] = const CompareVehicleDetailEntity(
        combinedKmPerLiter: 18.0,
        powerLabel: '106 hp',
        classLabel: 'No debe verse',
      )
      ..details['Aveo'] = const CompareVehicleDetailEntity(
        combinedKmPerLiter: 15.0,
        powerLabel: '99 hp',
      );
    final cubit = buildCompareCubit(selection: store, market: market);
    addTearDown(cubit.close);
    final table = buildCompareTableCubit(compare: cubit, vehicles: vehicles);
    addTearDown(table.close);
    await tester.pumpWidget(
      RepositoryProvider<CompareVersionLabeler>.value(
        value: FakeCompareVersionLabeler(),
        child: RepositoryProvider<CompareVersionsSource>.value(
          value: FakeCompareVersionsSource(),
          child: MultiBlocProvider(
            providers: [
              BlocProvider<CompareCubit>.value(value: cubit),
              BlocProvider<CompareTableCubit>.value(value: table),
            ],
            child: MaterialApp(
              home: ComparePage(
                selectorBuilder: (_) => const SizedBox(),
                visuals: _visuals,
                onOpenPicker: (_) async {},
              ),
            ),
          ),
        ),
      ),
    );
    await _settle(tester);
    expect(find.text('14.6'), findsOneWidget);
    expect(find.text(AppTexts.detailPowerRowLabel), findsNothing);
    final header = tester.element(find.byType(HeroHeaderWidget));
    market.switchTo('mx');
    await _settle(tester);
    await _settle(tester);
    // El valor viejo se desvanece antes de irse del árbol.
    await tester.pump(AppMotion.slow);
    expect(find.text('18.0'), findsOneWidget);
    expect(_bestPillAround('18.0'), findsOneWidget);
    // Reglas de México: potencia sí; clase no.
    expect(find.text(AppTexts.detailPowerRowLabel), findsOneWidget);
    expect(find.text('106 hp'), findsOneWidget);
    expect(find.text(AppTexts.detailClassRowLabel), findsNothing);
    expect(find.text('14.6'), findsNothing);
    // La pantalla no se refrescó completa: el encabezado es el mismo.
    expect(tester.element(find.byType(HeroHeaderWidget)), same(header));
  });
}
