import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_row_entity.dart';

/// Qué concluye el veredicto de una métrica.
enum CompareVerdictOutcome {
  /// Un vehículo es mejor que el resto.
  winner,

  /// Los mejores valores son iguales.
  tie,

  /// Falta el dato en algún vehículo: no se emite veredicto.
  missingData,
}

/// Veredicto de una métrica: quién gana, por cuánto, o por qué no hay.
///
/// Solo guarda posiciones y cifras ya redondeadas como en la tabla; el texto
/// lo arma la pantalla con los nombres.
class CompareVerdictEntity extends Equatable {
  const CompareVerdictEntity({
    required this.kind,
    required this.outcome,
    this.leaders = const [],
    this.runnerUp,
    this.winnerValue,
    this.runnerUpValue,
    this.difference,
    this.percent,
    this.missing = const [],
  });

  final CompareRowKind kind;
  final CompareVerdictOutcome outcome;

  /// Posiciones del ganador (una) o de los que empatan en lo mejor.
  final List<int> leaders;

  /// Segundo lugar contra el que se compara al ganador.
  final int? runnerUp;

  /// Cifras redondeadas como en la tabla.
  final double? winnerValue;
  final double? runnerUpValue;

  /// Distancia entre ambas, siempre positiva.
  final double? difference;

  /// Ventaja sobre el segundo lugar, en % entero; nula si no se puede calcular.
  final int? percent;

  /// Posiciones de los vehículos sin dato.
  final List<int> missing;

  @override
  List<Object?> get props => [
    kind,
    outcome,
    leaders,
    runnerUp,
    winnerValue,
    runnerUpValue,
    difference,
    percent,
    missing,
  ];
}
