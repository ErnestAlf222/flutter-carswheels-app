import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_row_entity.dart';

/// Barra de un vehículo en la gráfica: su cifra, o ninguna si no hay dato.
class CompareChartBarEntity extends Equatable {
  const CompareChartBarEntity({
    required this.slotIndex,
    required this.valueText,
    this.value,
    this.isBest = false,
  });

  /// Posición del vehículo en la selección.
  final int slotIndex;

  /// Cifra a dibujar; nula si el vehículo no tiene el dato o aún carga.
  final double? value;

  /// Texto con unidad, o el de "sin dato".
  final String valueText;

  /// Es el mejor valor de la métrica.
  final bool isBest;

  @override
  List<Object?> get props => [slotIndex, value, valueText, isBest];
}

/// Una métrica graficable: su fila de origen, su título y una barra por vehículo.
class CompareChartMetricEntity extends Equatable {
  const CompareChartMetricEntity({
    required this.kind,
    required this.label,
    required this.bars,
  });

  final CompareRowKind kind;
  final String label;
  final List<CompareChartBarEntity> bars;

  /// Mayor cifra de la métrica; la barra más larga.
  double get maxValue =>
      bars.map((bar) => bar.value ?? 0).fold(0, (a, b) => a > b ? a : b);

  /// En CO₂ y costo gana la cifra menor; la longitud sigue siendo proporcional.
  bool get lowerIsBetter =>
      kind == CompareRowKind.co2 || kind == CompareRowKind.annualCost;

  /// Ningún vehículo es el mejor (todos iguales): todas las barras brillan igual.
  bool get hasBest => bars.any((bar) => bar.isBest);

  @override
  List<Object?> get props => [kind, label, bars];
}
