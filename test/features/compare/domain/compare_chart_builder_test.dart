import 'package:flutter_test/flutter_test.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

const CompareVehicleDetailEntity _corolla = CompareVehicleDetailEntity(
  combinedKmPerLiter: 14.6,
  co2GramsPerKilometer: 151,
  annualFuelCostUsd: 1750,
  safetyStars: 5,
);

const CompareVehicleDetailEntity _camry = CompareVehicleDetailEntity(
  combinedKmPerLiter: 16.2,
  co2GramsPerKilometer: 120,
  annualFuelCostUsd: 1500,
  safetyStars: 5,
);

// Un eléctrico: sin consumo en km/l, con CO₂ en cero.
const CompareVehicleDetailEntity _electric = CompareVehicleDetailEntity(
  co2GramsPerKilometer: 0,
  annualFuelCostUsd: 600,
  safetyStars: 4,
);

List<CompareChartMetricEntity> _chart(
  List<CompareVehicleDetailEntity?> columns, {
  String market = MarketConfig.unitedStatesCode,
}) => const CompareChartBuilder().build(
  const CompareTableBuilder().build(marketCode: market, columns: columns),
);

CompareChartMetricEntity? _metric(
  List<CompareChartMetricEntity> metrics,
  CompareRowKind kind,
) => metrics.where((metric) => metric.kind == kind).firstOrNull;

void main() {
  group('valores numéricos de la tabla', () {
    test('las filas numéricas exponen la cifra y las de texto no', () {
      final sections = const CompareTableBuilder().build(
        marketCode: MarketConfig.unitedStatesCode,
        columns: const [_corolla, _electric],
      );
      final rows = {
        for (final section in sections)
          for (final row in section.rows) row.kind: row,
      };
      expect(rows[CompareRowKind.combinedConsumption]!.cells[0]!.value, 14.6);
      // Sin dato no es cero: la cifra es nula.
      expect(rows[CompareRowKind.combinedConsumption]!.cells[1]!.value, isNull);
      // El CO₂ en cero de un eléctrico es un dato real.
      expect(rows[CompareRowKind.co2]!.cells[1]!.value, 0);
      expect(rows[CompareRowKind.annualCost]!.cells[0]!.value, 1750);
    });
  });

  group('métricas de la gráfica', () {
    test('con datos en todos aparecen las 4, en su orden', () {
      final metrics = _chart(const [_corolla, _camry]);
      expect(metrics.map((metric) => metric.kind), [
        CompareRowKind.combinedConsumption,
        CompareRowKind.co2,
        CompareRowKind.annualCost,
        CompareRowKind.safety,
      ]);
    });

    test('una métrica con dato en un solo vehículo no aparece', () {
      final metrics = _chart(const [_corolla, _electric]);
      expect(_metric(metrics, CompareRowKind.combinedConsumption), isNull);
      expect(metrics, hasLength(3));
    });

    test('una columna que aún carga no cuenta como dato', () {
      final metrics = _chart(const [_corolla, null, _camry]);
      final consumption = _metric(metrics, CompareRowKind.combinedConsumption)!;
      expect(consumption.bars.map((bar) => bar.value), [14.6, null, 16.2]);
      // Con solo una cargada ya no hay con qué comparar.
      expect(_chart(const [_corolla, null, null]), isEmpty);
    });

    test('lo faltante lleva "—" y las cifras llevan su unidad', () {
      final metrics = _chart(const [_corolla, _camry, _electric]);
      final consumption = _metric(metrics, CompareRowKind.combinedConsumption)!;
      expect(consumption.bars.map((bar) => bar.valueText), [
        AppTexts.compareChartKmPerLiterValue('14.6'),
        AppTexts.compareChartKmPerLiterValue('16.2'),
        AppTexts.noDataLabel,
      ]);
    });

    test('el mejor es el de mayor consumo y el de menor CO₂ y costo', () {
      final metrics = _chart(const [_corolla, _camry, _electric]);
      List<bool> best(CompareRowKind kind) => [
        for (final bar in _metric(metrics, kind)!.bars) bar.isBest,
      ];
      expect(best(CompareRowKind.combinedConsumption), [false, true, false]);
      expect(best(CompareRowKind.co2), [false, false, true]);
      expect(best(CompareRowKind.annualCost), [false, false, true]);
      expect(_metric(metrics, CompareRowKind.co2)!.lowerIsBetter, isTrue);
      expect(
        _metric(metrics, CompareRowKind.combinedConsumption)!.lowerIsBetter,
        isFalse,
      );
    });

    test('con todos iguales no hay mejor y todas las barras brillan', () {
      final metrics = _chart(const [_corolla, _camry]);
      final safety = _metric(metrics, CompareRowKind.safety)!;
      expect(safety.hasBest, isFalse);
      expect(safety.maxValue, 5);
    });

    test('en México no hay costo anual ni estrellas', () {
      final metrics = _chart(const [
        _corolla,
        _camry,
      ], market: MarketConfig.mexicoCode);
      expect(_metric(metrics, CompareRowKind.annualCost), isNull);
      expect(_metric(metrics, CompareRowKind.safety), isNull);
    });
  });
}
