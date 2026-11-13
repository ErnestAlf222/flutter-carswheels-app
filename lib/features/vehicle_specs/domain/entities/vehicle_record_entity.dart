import 'package:equatable/equatable.dart';

/// Datos de un vehículo de FuelEconomy que usa el resumen.
class VehicleRecordEntity extends Equatable {
  const VehicleRecordEntity({
    required this.vehicleClass,
    required this.atvType,
    required this.combinedMpg,
  });

  /// Clase del vehículo en inglés, como la entrega la API.
  final String? vehicleClass;

  /// Tipo de combustible o motorización; vacío en gasolina normal.
  final String atvType;

  /// Millas por galón combinadas; nulo si la API no las trae o son 0.
  final double? combinedMpg;

  @override
  List<Object?> get props => [vehicleClass, atvType, combinedMpg];
}
