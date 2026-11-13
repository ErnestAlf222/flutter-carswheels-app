import 'package:equatable/equatable.dart';

/// Resumen de un grupo de modelos calculado con todas sus variantes leídas.
class GroupSummaryEntity extends Equatable {
  const GroupSummaryEntity({
    required this.vehicleClass,
    required this.minKmPerLiter,
    required this.maxKmPerLiter,
    required this.hasElectric,
    required this.hasPluginHybrid,
    required this.variantCount,
    this.hasFuelCell = false,
  });

  /// Clase original en inglés más frecuente; la traducción se hace al mostrarla.
  final String? vehicleClass;

  /// Rango de consumo solo de las variantes de combustión; nulo si ninguna tiene.
  final double? minKmPerLiter;
  final double? maxKmPerLiter;
  final bool hasElectric;
  final bool hasPluginHybrid;
  final bool hasFuelCell;

  /// Cuántas variantes se leyeron.
  final int variantCount;

  @override
  List<Object?> get props => [
    vehicleClass,
    minKmPerLiter,
    maxKmPerLiter,
    hasElectric,
    hasPluginHybrid,
    hasFuelCell,
    variantCount,
  ];
}
