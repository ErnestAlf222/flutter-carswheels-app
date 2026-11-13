import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/summaries_test_support.dart';

GroupSummaryEntity _summary({
  double? min = 7.2,
  double? max = 10.4,
  bool electric = false,
  bool plugin = false,
  bool fuelCell = false,
}) => GroupSummaryEntity(
  vehicleClass: 'Midsize Cars',
  minKmPerLiter: min,
  maxKmPerLiter: max,
  hasElectric: electric,
  hasPluginHybrid: plugin,
  hasFuelCell: fuelCell,
  variantCount: 3,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget consumption({SummarySlot? slot}) {
    final key = summaryKeyFor('Honda', 'Civic', 2020);
    return MaterialApp(
      home: BlocProvider<SummariesCubit>.value(
        value: buildMockSummariesCubit(slots: {key: ?slot}),
        child: const Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: ModelConsumptionWidget(
              brand: 'Honda',
              groupName: 'Civic',
              year: 2020,
            ),
          ),
        ),
      ),
    );
  }

  Size widgetSize(WidgetTester tester) =>
      tester.getSize(find.byType(ModelConsumptionWidget));

  void expectFixedWidth(WidgetTester tester) {
    expect(widgetSize(tester).width, UiConfig.modelConsumptionColumnWidth);
  }

  testWidgets('Loading muestra dos barras con las medidas de config', (
    tester,
  ) async {
    await tester.pumpWidget(consumption(slot: const SummaryLoading()));
    final bars = find.byType(SkeletonBarWidget);
    expect(bars, findsNWidgets(2));
    expect(
      tester.getSize(bars.first),
      const Size(
        UiConfig.summarySkeletonLongBarWidth,
        UiConfig.summarySkeletonBarHeight,
      ),
    );
    expect(
      tester.getSize(bars.last),
      const Size(
        UiConfig.summarySkeletonShortBarWidth,
        UiConfig.summarySkeletonBarHeight,
      ),
    );
    expectFixedWidth(tester);
  });

  testWidgets('Found con rango muestra la cifra y la unidad', (tester) async {
    await tester.pumpWidget(consumption(slot: SummaryFound(_summary())));
    await tester.pumpAndSettle();
    expect(find.text('7–10'), findsOneWidget);
    expect(find.text(AppTexts.consumptionUnitLabel), findsOneWidget);
    expect(find.byIcon(Symbols.bolt), findsNothing);
    final figure = tester.widget<Text>(find.text('7–10'));
    expect(figure.style, AppTextStyles.consumptionFigure);
    final unit = tester.widget<Text>(find.text(AppTexts.consumptionUnitLabel));
    expect(unit.style, AppTextStyles.consumptionUnit);
    expectFixedWidth(tester);
  });

  testWidgets('con min y max que redondean igual muestra una sola cifra', (
    tester,
  ) async {
    await tester.pumpWidget(
      consumption(slot: SummaryFound(_summary(min: 9.6, max: 10.2))),
    );
    await tester.pumpAndSettle();
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('con versiones eléctricas añade el icono mixto', (tester) async {
    await tester.pumpWidget(
      consumption(slot: SummaryFound(_summary(electric: true))),
    );
    await tester.pumpAndSettle();
    final icon = tester.widget<Icon>(find.byIcon(Symbols.bolt));
    expect(icon.size, UiConfig.powertrainBadgeIconSize);
    expect(
      find.bySemanticsLabel(AppTexts.mixedPowertrainSemanticLabel),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    expectFixedWidth(tester);
  });

  testWidgets('con híbrido enchufable también añade el icono', (tester) async {
    await tester.pumpWidget(
      consumption(slot: SummaryFound(_summary(plugin: true))),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Symbols.bolt), findsOneWidget);
  });

  testWidgets('solo eléctrico sin km/l muestra su etiqueta', (tester) async {
    await tester.pumpWidget(
      consumption(
        slot: SummaryFound(_summary(min: null, max: null, electric: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.electricLabel), findsOneWidget);
    expect(find.text(AppTexts.consumptionUnitLabel), findsNothing);
    expectFixedWidth(tester);
  });

  testWidgets('solo enchufable sin km/l muestra su etiqueta', (tester) async {
    await tester.pumpWidget(
      consumption(
        slot: SummaryFound(_summary(min: null, max: null, plugin: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.pluginHybridLabel), findsOneWidget);
  });

  testWidgets('con hidrógeno y km/l añade el icono mixto', (tester) async {
    await tester.pumpWidget(
      consumption(slot: SummaryFound(_summary(fuelCell: true))),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Symbols.bolt), findsOneWidget);
  });

  testWidgets('solo hidrógeno (Mirai) muestra Hidrógeno sin km/l', (
    tester,
  ) async {
    await tester.pumpWidget(
      consumption(
        slot: SummaryFound(_summary(min: null, max: null, fuelCell: true)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.hydrogenLabel), findsOneWidget);
    expect(find.text(AppTexts.consumptionUnitLabel), findsNothing);
    expect(find.byIcon(Symbols.bolt), findsNothing);
    expectFixedWidth(tester);
  });

  testWidgets('combinaciones sin km/l: una línea por etiqueta y en orden', (
    tester,
  ) async {
    final cases = <({bool e, bool p, bool f, List<String> labels})>[
      (
        e: true,
        p: true,
        f: false,
        labels: [AppTexts.electricLabel, AppTexts.pluginHybridLabel],
      ),
      (
        e: true,
        p: false,
        f: true,
        labels: [AppTexts.electricLabel, AppTexts.hydrogenLabel],
      ),
      (
        e: false,
        p: true,
        f: true,
        labels: [AppTexts.pluginHybridLabel, AppTexts.hydrogenLabel],
      ),
      (
        e: true,
        p: true,
        f: true,
        labels: [
          AppTexts.electricLabel,
          AppTexts.pluginHybridLabel,
          AppTexts.hydrogenLabel,
        ],
      ),
    ];
    for (final item in cases) {
      await tester.pumpWidget(
        consumption(
          slot: SummaryFound(
            _summary(
              min: null,
              max: null,
              electric: item.e,
              plugin: item.p,
              fuelCell: item.f,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      double previousTop = -1;
      for (final label in item.labels) {
        final finder = find.text(label);
        expect(finder, findsOneWidget);
        final text = tester.widget<Text>(finder);
        expect(text.style, AppTextStyles.caption);
        expect(text.textAlign, TextAlign.right);
        final top = tester.getTopLeft(finder).dy;
        expect(top, greaterThan(previousTop));
        previousTop = top;
      }
      expectFixedWidth(tester);
    }
  });

  testWidgets('las tres líneas con textScaler 2 no desbordan', (tester) async {
    final key = summaryKeyFor('Honda', 'Civic', 2020);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: BlocProvider<SummariesCubit>.value(
          value: buildMockSummariesCubit(
            slots: {
              key: SummaryFound(
                _summary(
                  min: null,
                  max: null,
                  electric: true,
                  plugin: true,
                  fuelCell: true,
                ),
              ),
            },
          ),
          child: const Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: ModelConsumptionWidget(
                brand: 'Honda',
                groupName: 'Civic',
                year: 2020,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(AppTexts.hydrogenLabel), findsOneWidget);
  });

  testWidgets('Found sin nada, Missing, Failed y sin slot no muestran nada', (
    tester,
  ) async {
    final empty = <SummarySlot?>[
      SummaryFound(_summary(min: null, max: null)),
      const SummaryMissing(),
      const SummaryFailed(),
      null,
    ];
    for (final slot in empty) {
      await tester.pumpWidget(consumption(slot: slot));
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsNothing);
      expect(find.byType(SkeletonBarWidget), findsNothing);
      expectFixedWidth(tester);
    }
  });
}
