import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_record_entity.dart';

/// Fuente de datos de los vehículos de un modelo.
abstract class VehicleSpecsDatasource {
  /// Ids de las opciones del modelo, en el orden de la API.
  Future<List<int>> fetchOptionIds(int year, String brand, String model);

  /// Nulo si la API no devuelve registro para el id.
  Future<VehicleRecordEntity?> fetchVehicle(int id);
}
