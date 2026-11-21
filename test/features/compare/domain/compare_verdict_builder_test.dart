import 'package:flutter_test/flutter_test.dart';

import 'package:cars_wheels_app/features/compare/compare.dart';

CompareChartBarEntity _bar(int index, double? value, {bool best = false}) =>
    CompareChartBarEntity(
      slotIndex: index,
      value: value,
      valueText: '$value',
      isBest: best,
    );

CompareChartMetricEntity _metric(
  CompareRowKind kind,
  List<CompareChartBarEntity> bars,
) => CompareChartMetricEntity(kind: kind, label: 'm', bars: bars);

// Métrica armada con el mismo camino de la pantalla: detalles, tabla y gráfica.
CompareChartMetricEntity _real(
  CompareRowKind kind,
  List<CompareVehicleDetailEntity?> columns,
) {
  final sections = const CompareTableBuilder().build(
    marketCode: 'us',
    columns: columns,
  );
  return const CompareChartBuilder()
      .build(sections)
      .firstWhere((metric) => metric.kind == kind);
}

void main() {
  const builder = CompareVerdictBuilder();

  group('consumo (gana el mayor)', () {
    test('dos autos: ganador, diferencia y porcentaje', () {
      final verdict = builder.build(
        _metric(CompareRowKind.combinedConsumption, [
          _bar(0, 14.6),
          _bar(1, 16.0, best: true),
        ]),
      )!;
      expect(verdict.outcome, CompareVerdictOutcome.winner);
      expect(verdict.leaders, [1]);
      expect(verdict.runnerUp, 0);
      expect(verdict.difference, 1.4);
      // 1.4 / 14.6 = 9.6 % → 10 %.
      expect(verdict.percent, 10);
    });

    test('tres autos: se compara contra el segundo lugar, no el último', () {
      final verdict = builder.build(
        _metric(CompareRowKind.combinedConsumption, [
          _bar(0, 10.0),
          _bar(1, 15.0, best: true),
          _bar(2, 12.0),
        ]),
      )!;
      expect(verdict.leaders, [1]);
      expect(verdict.runnerUp, 2);
      expect(verdict.difference, 3.0);
      expect(verdict.percent, 25);
    });

    test('usa las cifras redondeadas como la tabla', () {
      final verdict = builder.build(
        _metric(CompareRowKind.combinedConsumption, [
          _bar(0, 14.64),
          _bar(1, 16.04, best: true),
        ]),
      )!;
      expect(verdict.winnerValue, 16.0);
      expect(verdict.runnerUpValue, 14.6);
      expect(verdict.difference, 1.4);
    });

    test('empate de todos: sin ganador', () {
      final verdict = builder.build(
        _metric(CompareRowKind.combinedConsumption, [
          _bar(0, 15.0),
          _bar(1, 15.0),
          _bar(2, 15.0),
        ]),
      )!;
      expect(verdict.outcome, CompareVerdictOutcome.tie);
      expect(verdict.leaders, [0, 1, 2]);
    });

    test('empate en lo mejor con un tercero peor: empatan los líderes', () {
      final verdict = builder.build(
        _metric(CompareRowKind.combinedConsumption, [
          _bar(0, 16.0, best: true),
          _bar(1, 16.0, best: true),
          _bar(2, 12.0),
        ]),
      )!;
      expect(verdict.outcome, CompareVerdictOutcome.tie);
      expect(verdict.leaders, [0, 1]);
    });

    test('falta el dato de un auto: sin veredicto y se indica cuál', () {
      final verdict = builder.build(
        _metric(CompareRowKind.combinedConsumption, [
          _bar(0, 14.0),
          _bar(1, null),
          _bar(2, 16.0, best: true),
        ]),
      )!;
      expect(verdict.outcome, CompareVerdictOutcome.missingData);
      expect(verdict.missing, [1]);
      expect(verdict.percent, isNull);
      expect(verdict.leaders, isEmpty);
    });
  });

  group('CO₂ y costo anual (gana el menor)', () {
    test('CO₂: el menor gana y el porcentaje es sobre el segundo lugar', () {
      final verdict = builder.build(
        _metric(CompareRowKind.co2, [_bar(0, 150), _bar(1, 120, best: true)]),
      )!;
      expect(verdict.leaders, [1]);
      expect(verdict.runnerUp, 0);
      expect(verdict.difference, 30);
      expect(verdict.percent, 20);
    });

    test('CO₂ cero (eléctrico) contra otro: 100 %', () {
      final verdict = builder.build(
        _metric(CompareRowKind.co2, [_bar(0, 0, best: true), _bar(1, 200)]),
      )!;
      expect(verdict.percent, 100);
    });

    test('costo anual con tres autos: segundo lugar es el siguiente menor', () {
      final verdict = builder.build(
        _metric(CompareRowKind.annualCost, [
          _bar(0, 2000),
          _bar(1, 1500, best: true),
          _bar(2, 1600),
        ]),
      )!;
      expect(verdict.runnerUp, 2);
      expect(verdict.difference, 100);
      // 100 / 1600 = 6.25 % → 6 %.
      expect(verdict.percent, 6);
    });

    test('costo anual igual: empate', () {
      final verdict = builder.build(
        _metric(CompareRowKind.annualCost, [_bar(0, 1500), _bar(1, 1500)]),
      )!;
      expect(verdict.outcome, CompareVerdictOutcome.tie);
    });
  });

  group('NHTSA (gana el mayor)', () {
    test('mejor calificación sin inventar porcentaje de más', () {
      final verdict = builder.build(
        _metric(CompareRowKind.safety, [_bar(0, 5, best: true), _bar(1, 4)]),
      )!;
      expect(verdict.outcome, CompareVerdictOutcome.winner);
      expect(verdict.winnerValue, 5);
      expect(verdict.runnerUpValue, 4);
    });

    test('dato faltante en un auto: sin veredicto', () {
      final verdict = builder.build(
        _metric(CompareRowKind.safety, [
          _bar(0, 5, best: true),
          _bar(1, 4),
          _bar(2, null),
        ]),
      )!;
      expect(verdict.outcome, CompareVerdictOutcome.missingData);
      expect(verdict.missing, [2]);
    });
  });

  test('una métrica que no es de las cuatro no tiene veredicto', () {
    expect(
      builder.build(
        _metric(CompareRowKind.power, [_bar(0, 1), _bar(1, 2, best: true)]),
      ),
      isNull,
    );
  });

  test('con datos reales de la tabla coincide con el mejor resaltado', () {
    final metric = _real(CompareRowKind.combinedConsumption, [
      const CompareVehicleDetailEntity(combinedKmPerLiter: 14.6),
      const CompareVehicleDetailEntity(combinedKmPerLiter: 16.0),
    ]);
    final verdict = builder.build(metric)!;
    expect(verdict.leaders, [1]);
    expect(verdict.percent, 10);
  });

  test('con un auto sin dato en la tabla, la métrica indica quién falta', () {
    final metric = _real(CompareRowKind.combinedConsumption, [
      const CompareVehicleDetailEntity(combinedKmPerLiter: 14.6),
      const CompareVehicleDetailEntity(combinedKmPerLiter: 16.0),
      const CompareVehicleDetailEntity(),
    ]);
    final verdict = builder.build(metric)!;
    expect(verdict.outcome, CompareVerdictOutcome.missingData);
    expect(verdict.missing, [2]);
  });
}
