import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

import '../../../support/compare_test_support.dart';

final CompareSlotVisuals _visuals = CompareSlotVisuals(
  photoBuilder: (context, slot) => const ColoredBox(color: Colors.grey),
  logoBuilder: (context, slot, size) => SizedBox(width: size, height: size),
);

const CompareVehicleDetailEntity _corolla = CompareVehicleDetailEntity(
  versionLabel: 'Automática · 4 cil · 2.0 L',
  combinedKmPerLiter: 14.6,
  co2GramsPerKilometer: 151,
  annualFuelCostUsd: 1750,
  fuelLabel: 'Gasolina regular',
);

const CompareVehicleDetailEntity _camry = CompareVehicleDetailEntity(
  combinedKmPerLiter: 16.2,
  co2GramsPerKilometer: 120,
  annualFuelCostUsd: 1500,
  fuelLabel: 'Gasolina regular',
);

const CompareVehicleDetailEntity _electric = CompareVehicleDetailEntity(
  co2GramsPerKilometer: 0,
  annualFuelCostUsd: 600,
  fuelLabel: 'Electricidad',
);

List<CompareSlotEntity> _slots(int count) => [
  compareSlot(model: 'Corolla'),
  compareSlot(model: 'Camry'),
  compareSlot(model: 'Model 3', brand: 'Tesla'),
].take(count).toList();

class _Page {
  const _Page({required this.cubit, required this.vehicles});

  final CompareCubit cubit;
  final FakeCompareVehicleSource vehicles;
}

Future<_Page> _pump(
  WidgetTester tester, {
  required List<CompareSlotEntity> initial,
  double textScale = 1.0,
  bool disableAnimations = true,
  void Function(FakeCompareVehicleSource vehicles)? configure,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  addTearDown(tester.view.resetViewInsets);
  final store = InMemoryCompareSelection();
  await store.write('us', initial);
  final vehicles = FakeCompareVehicleSource()
    ..details['Corolla'] = _corolla
    ..details['Camry'] = _camry
    ..details['Model 3'] = _electric;
  configure?.call(vehicles);
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
    ];
  final cubit = buildCompareCubit(
    selection: store,
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
    RepositoryProvider<CompareVersionsSource>.value(
      value: versions,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CompareCubit>.value(value: cubit),
          BlocProvider<CompareTableCubit>.value(value: table),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: disableAnimations,
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
  );
  await _settle(tester);
  return _Page(cubit: cubit, vehicles: vehicles);
}

Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 4; i++) {
    await tester.pump();
  }
}

Finder get _chartButton => find.byKey(const ValueKey('compare-chart-button'));

// El botón existe, se ve y recibe toques.
bool _chartButtonShown(WidgetTester tester) {
  if (_chartButton.evaluate().isEmpty) return false;
  final ignore = tester.widget<IgnorePointer>(
    find.ancestor(of: _chartButton, matching: find.byType(IgnorePointer)).first,
  );
  final opacity = tester.widget<AnimatedOpacity>(
    find.ancestor(of: _chartButton, matching: find.byType(AnimatedOpacity)),
  );
  return !ignore.ignoring && opacity.opacity == 1.0;
}

Finder get _painters => find.byWidgetPredicate(
  (widget) => widget is CustomPaint && widget.painter is CompareChartPainter,
);

CompareChartPainter _painter(WidgetTester tester) =>
    (tester.widget<CustomPaint>(_painters)).painter! as CompareChartPainter;

// Lo que el painter dibuja, con un lienzo que registra las llamadas.
List<Paint> _barPaints(CompareChartPainter painter, {required bool glow}) {
  final canvas = TestRecordingCanvas();
  painter.paint(
    canvas,
    Size(300, CompareChartPainter.totalHeight(3, TextScaler.noScaling)),
  );
  return [
    for (final call in canvas.invocations)
      if (call.invocation.memberName == #drawRRect)
        if (((call.invocation.positionalArguments[1] as Paint).maskFilter !=
                null) ==
            glow)
          call.invocation.positionalArguments[1] as Paint,
  ];
}

Future<void> _openChart(WidgetTester tester) async {
  await tester.tap(_chartButton);
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('botón de la gráfica', () {
    testWidgets('con 2 o más vehículos con datos aparece y abre la hoja', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      expect(_chartButtonShown(tester), isTrue);
      expect(find.byIcon(Symbols.bar_chart), findsOneWidget);
      await _openChart(tester);
      expect(find.text(AppTexts.compareChartTitle), findsOneWidget);
    });

    testWidgets('con 0 o 1 vehículo no se ofrece', (tester) async {
      await _pump(tester, initial: _slots(1));
      expect(_chartButtonShown(tester), isFalse);
    });

    testWidgets('mientras carga no hay métricas y no se ofrece', (
      tester,
    ) async {
      final gate = Completer<void>();
      await _pump(
        tester,
        initial: _slots(2),
        configure: (vehicles) {
          vehicles.gates['Corolla'] = gate;
          vehicles.gates['Camry'] = gate;
        },
      );
      expect(_chartButtonShown(tester), isFalse);
      gate.complete();
      await _settle(tester);
      expect(_chartButtonShown(tester), isTrue);
    });

    testWidgets('se oculta con el teclado abierto', (tester) async {
      await _pump(tester, initial: _slots(2));
      expect(_chartButtonShown(tester), isTrue);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      expect(_chartButtonShown(tester), isFalse);
      tester.view.resetViewInsets();
      await tester.pump();
      expect(_chartButtonShown(tester), isTrue);
    });

    testWidgets('queda sobre la barra de navegación, abajo a la derecha', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      final rect = tester.getRect(_chartButton);
      expect(rect.right, 360 - ScrollConfig.topButtonRightMargin);
      expect(
        rect.bottom,
        800 - NavConfig.footprint - ScrollConfig.topButtonNavGap,
      );
    });
  });

  group('hoja de la gráfica', () {
    testWidgets('fondo tinta sólido, título y solo métricas con 2 datos', (
      tester,
    ) async {
      // Corolla y el eléctrico: el consumo solo existe en uno.
      await _pump(tester, initial: [_slots(3)[0], _slots(3)[2]]);
      await _openChart(tester);
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, AppColors.ink);
      expect(find.text(AppTexts.compareChartTitle), findsOneWidget);
      expect(find.text(AppTexts.compareChartCo2), findsOneWidget);
      expect(find.text(AppTexts.compareChartAnnualCost), findsOneWidget);
      // "Consumo" también es un título de sección de la tabla, fuera de la hoja.
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text(AppTexts.compareChartConsumption),
        ),
        findsNothing,
      );
    });

    testWidgets('cambiar de métrica cambia la gráfica', (tester) async {
      await _pump(tester, initial: _slots(3));
      await _openChart(tester);
      expect(_painter(tester).metric.kind, CompareRowKind.combinedConsumption);
      await tester.tap(find.text(AppTexts.compareChartCo2));
      await tester.pump();
      expect(_painter(tester).metric.kind, CompareRowKind.co2);
      expect(find.text(AppTexts.compareChartHintLower), findsOneWidget);
    });

    testWidgets('una barra por vehículo con datos y ninguna sin ellos', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(3));
      await _openChart(tester);
      // Consumo: el eléctrico no tiene dato, así que solo hay 2 barras.
      final painter = _painter(tester);
      final bars = _barPaints(painter, glow: false);
      expect(bars, hasLength(2));
      // Cada barra tiene sus dos capas de halo desenfocado.
      expect(_barPaints(painter, glow: true), hasLength(4));
      // Con CO₂, el eléctrico vale cero: sin barra, pero con su "0 g/km".
      await tester.tap(find.text(AppTexts.compareChartCo2));
      await tester.pump();
      expect(_barPaints(_painter(tester), glow: false), hasLength(2));
      expect(_painter(tester).metric.bars[2].valueText, '0 g/km');
    });

    testWidgets('el mejor lleva el neón completo y los demás atenuado', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(3));
      await _openChart(tester);
      final bars = _barPaints(_painter(tester), glow: false);
      // Corolla 14.6 (atenuada) y Camry 16.2 (mejor), en ese orden.
      expect(bars.map((paint) => paint.color.toARGB32()), [
        AppColors.chartNeonDim.toARGB32(),
        AppColors.chartNeon.toARGB32(),
      ]);
      final glows = _barPaints(_painter(tester), glow: true);
      expect(glows.map((paint) => paint.color.toARGB32()).toSet(), {
        AppColors.chartNeonDimGlow.toARGB32(),
        AppColors.chartNeonGlow.toARGB32(),
      });
    });

    testWidgets('con menor-es-mejor la longitud sigue el valor', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      await _openChart(tester);
      await tester.tap(find.text(AppTexts.compareChartCo2));
      await tester.pump();
      final canvas = TestRecordingCanvas();
      _painter(tester).paint(canvas, const Size(300, 200));
      final widths = [
        for (final call in canvas.invocations)
          if (call.invocation.memberName == #drawRRect &&
              (call.invocation.positionalArguments[1] as Paint).maskFilter ==
                  null)
            (call.invocation.positionalArguments[0] as RRect).width,
      ];
      // 151 g/km es la barra más larga; 120 g/km, la mejor, es más corta.
      expect(widths, hasLength(2));
      expect(widths[0], greaterThan(widths[1]));
      expect(widths[0] / widths[1], closeTo(151 / 120, 0.001));
      expect(_painter(tester).metric.bars[1].isBest, isTrue);
    });

    testWidgets('sin animaciones las barras aparecen completas', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      await _openChart(tester);
      expect(_painter(tester).progress, 1.0);
    });

    testWidgets('con animaciones crecen desde cero hasta completas', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2), disableAnimations: false);
      await _openChart(tester);
      // Con la hoja ya abierta, las barras van a medio crecer.
      await tester.pump(const Duration(milliseconds: 150));
      final progress = _painter(tester).progress;
      expect(progress, lessThan(1.0));
      await tester.pump(
        const Duration(milliseconds: CompareConfig.chartGrowMilliseconds),
      );
      expect(_painter(tester).progress, 1.0);
      // Otra métrica vuelve a crecer desde cero.
      await tester.tap(find.text(AppTexts.compareChartCo2));
      await tester.pump();
      expect(_painter(tester).progress, lessThan(1.0));
      await tester.pumpAndSettle();
      expect(_painter(tester).progress, 1.0);
    });

    testWidgets('el painter sólo repinta si cambia algo', (tester) async {
      await _pump(tester, initial: _slots(2));
      await _openChart(tester);
      final painter = _painter(tester);
      final same = CompareChartPainter(
        metric: painter.metric,
        names: painter.names,
        progress: painter.progress,
        textScaler: painter.textScaler,
      );
      expect(painter.shouldRepaint(same), isFalse);
      expect(
        painter.shouldRepaint(
          CompareChartPainter(
            metric: painter.metric,
            names: painter.names,
            progress: 0.5,
            textScaler: painter.textScaler,
          ),
        ),
        isTrue,
      );
    });
  });

  group('hoja de ayuda', () {
    testWidgets('no se abre sola y el botón muestra los 4 pasos', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      expect(find.text(AppTexts.compareHelpSheetTitle), findsNothing);
      await tester.tap(find.byIcon(Symbols.help));
      await tester.pumpAndSettle();
      expect(find.text(AppTexts.compareHelpSheetTitle), findsOneWidget);
      for (final step in AppTexts.compareHelpSteps) {
        expect(find.text(step), findsOneWidget);
      }
      for (int number = 1; number <= 4; number++) {
        expect(find.text('$number'), findsOneWidget);
      }
      expect(find.text(AppTexts.compareHelpFootnote), findsOneWidget);
    });

    testWidgets('con menos de 2 vehículos el texto pide al menos 2', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(1));
      expect(
        find.text('Agrega al menos 2 vehículos (hasta 3) para comparar'),
        findsOneWidget,
      );
    });
  });

  group('pastilla y hoja de versiones', () {
    testWidgets('etiqueta "Versión", valor y chevron en un círculo', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      expect(
        find.text(AppTexts.compareVersionPillOverline.toUpperCase()),
        findsNWidgets(2),
      );
      expect(find.text(AppTexts.compareVersionDefaultLabel), findsNWidgets(2));
      expect(find.byIcon(Symbols.expand_more), findsNWidgets(2));
      final value = tester.widget<Text>(
        find.text(AppTexts.compareVersionDefaultLabel).first,
      );
      expect(value.maxLines, 1);
      expect(value.overflow, TextOverflow.ellipsis);
    });

    testWidgets('abierta invierte el chevron y pasa el borde a tinta', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      await tester.tap(find.byType(CompareVersionPillWidget).first);
      await _settle(tester);
      expect(find.byIcon(Symbols.expand_less), findsOneWidget);
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(CompareVersionPillWidget).first,
              matching: find.byType(Material),
            )
            .first,
      );
      expect(
        (material.shape! as RoundedRectangleBorder).side.color,
        AppColors.ink,
      );
      // Al cerrar la hoja vuelve a su estado normal.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byIcon(Symbols.expand_less), findsNothing);
      expect(find.byIcon(Symbols.expand_more), findsNWidgets(2));
    });

    testWidgets('con una versión que aún carga muestra "Cargando…"', (
      tester,
    ) async {
      final gate = Completer<void>();
      await _pump(
        tester,
        initial: [_slots(2)[0].withVersion('Corolla LE'), _slots(2)[1]],
        configure: (vehicles) => vehicles.gates['Corolla'] = gate,
      );
      expect(
        find.text(AppTexts.compareVersionPillLoadingValue),
        findsOneWidget,
      );
      gate.complete();
      await _settle(tester);
      expect(find.text(AppTexts.compareVersionPillLoadingValue), findsNothing);
      expect(find.text(_corolla.versionLabel!), findsOneWidget);
    });

    testWidgets('la hoja trae marca y modelo, y un solo amarillo: el check', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(2));
      await tester.tap(find.byType(CompareVersionPillWidget).first);
      await _settle(tester);
      final sheet = find.byType(BottomSheet);
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(
            AppTexts.compareVersionSheetTitle('Toyota', 'Corolla'),
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(AppTexts.compareVersionDefaultLabel),
        ),
        findsOneWidget,
      );
      // Sin versión elegida, la predeterminada lleva el check amarillo.
      Finder yellow() => find.descendant(
        of: sheet,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == AppColors.accent,
        ),
      );
      expect(yellow(), findsOneWidget);
      expect(
        find.descendant(of: sheet, matching: find.byIcon(Symbols.check)),
        findsOneWidget,
      );
      final row = tester.getSize(
        find
            .ancestor(
              of: find.text(AppTexts.compareVersionDefaultLabel).last,
              matching: find.byType(InkWell),
            )
            .first,
      );
      expect(
        row.height,
        greaterThanOrEqualTo(CompareConfig.versionRowMinHeight),
      );
    });
  });

  group('alineación de columnas', () {
    testWidgets(
      'etiqueta, valor, banda y espacio comparten el borde izquierdo',
      (tester) async {
        await _pump(tester, initial: _slots(3));
        final slotLefts = [
          for (int i = 0; i < 3; i++)
            tester.getRect(find.byType(CompareFilledSlotWidget).at(i)).left,
        ];
        final label = find.text(AppTexts.compareRowCombinedConsumption);
        final labelLeft = tester.getRect(label).left;
        // Con el desplazamiento la banda queda fija arriba.
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pump();
        final bandLefts = [
          tester.getRect(find.text('Toyota Corolla')).left,
          tester.getRect(find.text('Toyota Camry')).left,
          tester.getRect(find.text('Tesla Model 3')).left,
        ];
        expect(bandLefts, slotLefts);
        // La primera columna: etiqueta y valor en el mismo borde que el espacio.
        expect(labelLeft, slotLefts[0]);
        // Valores: el normal y el mejor (con relleno) empiezan igual.
        final normal = find.text('14.6');
        final best = find.text('16.2');
        expect(tester.getRect(normal).left, slotLefts[0]);
        expect(tester.getRect(best).left, slotLefts[1]);
        // El relleno del mejor sobresale hacia afuera, sin mover el texto.
        final pill = find.ancestor(
          of: best,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color ==
                    AppColors.accentTint,
          ),
        );
        expect(tester.getRect(pill).left, lessThan(slotLefts[1]));
      },
    );
  });

  group('sin desbordes a 360 dp y escala 1.3', () {
    testWidgets('pantalla con hojas de ayuda, versión y gráfica', (
      tester,
    ) async {
      await _pump(tester, initial: _slots(3), textScale: 1.3);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Symbols.help));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CompareVersionPillWidget).first);
      await _settle(tester);
      expect(tester.takeException(), isNull);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await _openChart(tester);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(AppTexts.compareChartAnnualCost));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
