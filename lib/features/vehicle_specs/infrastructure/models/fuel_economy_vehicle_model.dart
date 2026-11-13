import 'package:cars_wheels_app/core/core.dart';

/// Registro de un vehículo de FuelEconomy con los campos en texto.
class FuelEconomyVehicleModel {
  const FuelEconomyVehicleModel({
    required this.vehicleClass,
    required this.atvType,
    required this.combinedMpg,
    required this.combinedMpgPrecise,
  });

  /// Tolera campos ausentes o vacíos; falla si la raíz no es un objeto.
  factory FuelEconomyVehicleModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingFailure('El registro del vehículo no es un objeto');
    }
    return FuelEconomyVehicleModel(
      vehicleClass: _readText(json[VehicleSpecsConfig.vehicleClassKey]),
      atvType: _readText(json[VehicleSpecsConfig.atvTypeKey]) ?? '',
      combinedMpg: _readText(json[VehicleSpecsConfig.combinedMpgKey]),
      combinedMpgPrecise: _readText(
        json[VehicleSpecsConfig.combinedMpgPreciseKey],
      ),
    );
  }

  final String? vehicleClass;
  final String atvType;
  final String? combinedMpg;
  final String? combinedMpgPrecise;

  // Texto sin espacios sobrantes; nulo si falta o queda vacío.
  static String? _readText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
