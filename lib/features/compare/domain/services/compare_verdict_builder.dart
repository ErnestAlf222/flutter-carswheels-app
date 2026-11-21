import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_chart_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_row_entity.dart';
import 'package:cars_wheels_app/features/compare/domain/entities/compare_verdict_entity.dart';

/// Concluye quién gana una métrica con los mismos datos y criterio de la tabla.
///
/// Toma el mejor valor que la tabla ya marcó y compara las cifras redondeadas
/// como ahí se muestran. Con tres vehículos el ganador se mide contra el
/// segundo lugar. Si falta el dato en alguno no hay veredicto de esa métrica.
class CompareVerdictBuilder {
  const CompareVerdictBuilder();

  /// Nulo solo si la métrica no es graficable.
  CompareVerdictEntity? build(CompareChartMetricEntity metric) {
    if (!_supported.contains(metric.kind)) return null;
    final missing = [
      for (final bar in metric.bars)
        if (bar.value == null) bar.slotIndex,
    ];
    if (missing.isNotEmpty) {
      return CompareVerdictEntity(
        kind: metric.kind,
        outcome: CompareVerdictOutcome.missingData,
        missing: missing,
      );
    }
    final digits = _digitsOf(metric.kind);
    final shown = {
      for (final bar in metric.bars)
        bar.slotIndex: double.parse(bar.value!.toStringAsFixed(digits)),
    };
    final leaders = [
      for (final bar in metric.bars)
        if (bar.isBest) bar.slotIndex,
    ];
    // Sin ninguno marcado, todas las cifras son iguales.
    if (leaders.length != 1) {
      return CompareVerdictEntity(
        kind: metric.kind,
        outcome: CompareVerdictOutcome.tie,
        leaders: leaders.isEmpty ? shown.keys.toList() : leaders,
      );
    }
    final winner = leaders.single;
    final others = [
      for (final index in shown.keys)
        if (index != winner) index,
    ];
    final runnerUp = others.reduce((a, b) {
      final better = metric.lowerIsBetter
          ? shown[b]! < shown[a]!
          : shown[b]! > shown[a]!;
      return better ? b : a;
    });
    final winnerValue = shown[winner]!;
    final runnerUpValue = shown[runnerUp]!;
    final difference = (winnerValue - runnerUpValue).abs();
    // Ventaja sobre el segundo lugar; sin base no se inventa un porcentaje.
    final percent = runnerUpValue == 0
        ? null
        : (difference / runnerUpValue * 100).round();
    return CompareVerdictEntity(
      kind: metric.kind,
      outcome: CompareVerdictOutcome.winner,
      leaders: [winner],
      runnerUp: runnerUp,
      winnerValue: winnerValue,
      runnerUpValue: runnerUpValue,
      difference: double.parse(difference.toStringAsFixed(digits)),
      percent: percent,
    );
  }

  static const Set<CompareRowKind> _supported = {
    CompareRowKind.combinedConsumption,
    CompareRowKind.co2,
    CompareRowKind.annualCost,
    CompareRowKind.safety,
  };

  // Decimales con que la tabla muestra la cifra de cada métrica.
  static int _digitsOf(CompareRowKind kind) =>
      kind == CompareRowKind.combinedConsumption
      ? TextConfig.kmPerLiterFractionDigits
      : 0;
}
