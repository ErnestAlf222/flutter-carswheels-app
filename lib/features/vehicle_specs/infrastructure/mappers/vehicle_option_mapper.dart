import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_option_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/fuel_economy_options_model.dart';

/// Convierte las opciones de la API en entidades del dominio.
class VehicleOptionMapper {
  const VehicleOptionMapper._();

  static List<VehicleOptionEntity> toEntities(FuelEconomyOptionsModel model) {
    return [
      for (final item in model.items)
        VehicleOptionEntity(id: item.id, text: item.text),
    ];
  }
}
