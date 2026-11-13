import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/detail_test_support.dart';

void main() {
  setUpAll(disableFontFetching);

  Widget card(VehicleDetailEntity detail, {double textScale = 1}) => detailHost(
    SingleChildScrollView(child: DetailEfficiencyCardWidget(detail: detail)),
    textScale: textScale,
  );

  // Segmentos de la barra: los que tienen degradado están rellenos.
  List<bool> segments(WidgetTester tester) {
    final boxes = tester
        .widgetList<Container>(find.byType(Container))
        .where(
          (c) =>
              c.constraints?.maxWidth == UiConfig.efficiencyScoreSegmentWidth,
        );
    return [
      for (final box in boxes)
        (box.decoration! as BoxDecoration).gradient != null,
    ];
  }

  testWidgets('combustión: ciudad, carretera, CO₂ y las dos puntuaciones', (
    tester,
  ) async {
    await tester.pumpWidget(
      card(
        testDetail(
          cityKmPerLiter: 13.1,
          highwayKmPerLiter: 17.0,
          co2GramsPerKilometer: 159.7,
          fuelScore: 8,
          emissionsScore: 6,
        ),
      ),
    );
    expect(find.text(AppTexts.efficiencyTitle), findsOneWidget);
    expect(find.text('13.1 km/l'), findsOneWidget);
    expect(find.text(AppTexts.cityConsumptionLabel), findsOneWidget);
    expect(find.text('17.0 km/l'), findsOneWidget);
    expect(find.text(AppTexts.highwayConsumptionLabel), findsOneWidget);
    expect(find.text('160 g/km'), findsOneWidget);
    expect(find.text(AppTexts.co2Label), findsOneWidget);
    expect(find.text(AppTexts.fuelScoreLabel), findsOneWidget);
    expect(find.text(AppTexts.emissionsScoreLabel), findsOneWidget);
    expect(find.text(AppTexts.totalRangeLabel), findsNothing);
    expect(find.text(AppTexts.electricConsumptionLabel), findsNothing);
  });

  testWidgets('eléctrico: autonomía, consumo eléctrico y CO₂ de 0 g/km', (
    tester,
  ) async {
    await tester.pumpWidget(
      card(
        testDetail(
          powertrain: Powertrain.electric,
          combinedKmPerLiter: null,
          totalRangeKilometers: 531.1,
          electricConsumptionKwhPer100Kilometers: 16.1,
          co2GramsPerKilometer: 0,
        ),
      ),
    );
    expect(find.text('531 km'), findsOneWidget);
    expect(find.text(AppTexts.totalRangeLabel), findsOneWidget);
    expect(find.text('16.1 kWh/100 km'), findsOneWidget);
    expect(find.text('0 g/km'), findsOneWidget);
    expect(find.text(AppTexts.cityConsumptionLabel), findsNothing);
  });

  testWidgets('enchufable: autonomía eléctrica, consumo y gasolina híbrida', (
    tester,
  ) async {
    await tester.pumpWidget(
      card(
        testDetail(
          powertrain: Powertrain.pluginHybrid,
          electricRangeKilometers: 40.2,
          electricConsumptionKwhPer100Kilometers: 15.5,
          hybridGasKmPerLiter: 23.1,
        ),
      ),
    );
    expect(find.text('40 km'), findsOneWidget);
    expect(find.text(AppTexts.electricRangeLabel), findsOneWidget);
    expect(find.text('15.5 kWh/100 km'), findsOneWidget);
    expect(find.text('23.1 km/l'), findsOneWidget);
    expect(find.text(AppTexts.hybridGasConsumptionLabel), findsOneWidget);
    expect(find.text(AppTexts.totalRangeLabel), findsNothing);
  });

  testWidgets('hidrógeno: autonomía total y puntuaciones', (tester) async {
    await tester.pumpWidget(
      card(
        testDetail(
          powertrain: Powertrain.fuelCell,
          totalRangeKilometers: 502.1,
          fuelScore: 10,
          emissionsScore: 10,
        ),
      ),
    );
    expect(find.text('502 km'), findsOneWidget);
    expect(find.text(AppTexts.co2Label), findsNothing);
    expect(find.text(AppTexts.fuelScoreLabel), findsOneWidget);
  });

  testWidgets('sin ningún dato no ocupa espacio', (tester) async {
    await tester.pumpWidget(card(testDetail()));
    expect(find.text(AppTexts.efficiencyTitle), findsNothing);
    final size = tester.getSize(find.byType(DetailEfficiencyCardWidget));
    expect(size.height, 0);
  });

  testWidgets('una sola puntuación muestra solo su fila', (tester) async {
    await tester.pumpWidget(card(testDetail(emissionsScore: 4)));
    expect(find.text(AppTexts.emissionsScoreLabel), findsOneWidget);
    expect(find.text(AppTexts.fuelScoreLabel), findsNothing);
    expect(find.text(AppTexts.efficiencyTitle), findsOneWidget);
  });

  testWidgets('la barra rellena N segmentos y los describe', (tester) async {
    await tester.pumpWidget(card(testDetail(fuelScore: 7)));
    final filled = segments(tester);
    expect(filled, hasLength(UiConfig.efficiencyScoreSegmentCount));
    expect(filled.where((value) => value), hasLength(7));
    expect(filled.take(7).every((value) => value), isTrue);
    expect(
      find.bySemanticsLabel(AppTexts.scoreSemanticLabel(7)),
      findsOneWidget,
    );
  });

  testWidgets('con textScaler 2 no desborda', (tester) async {
    await tester.pumpWidget(
      card(
        testDetail(
          powertrain: Powertrain.pluginHybrid,
          electricRangeKilometers: 40.2,
          electricConsumptionKwhPer100Kilometers: 15.5,
          hybridGasKmPerLiter: 23.1,
          co2GramsPerKilometer: 48.5,
          fuelScore: 10,
          emissionsScore: 9,
        ),
        textScale: 2,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('con disableAnimations no hay animación propia', (tester) async {
    await tester.pumpWidget(card(testDetail(fuelScore: 5)));
    expect(find.byType(AnimatedContainer), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
