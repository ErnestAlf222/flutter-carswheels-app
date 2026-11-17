import 'package:cars_wheels_app/features/safety/domain/entities/safety_rating_entity.dart';

/// Calificaciones de NHTSA en sus tres pasos.
abstract class NhtsaSafetyRatingsDatasource {
  /// Nombres de modelo con calificaciones para la marca y el año.
  Future<List<String>> fetchModelNames(int year, String make);

  /// Ids de las versiones de un modelo con el nombre exacto de NHTSA.
  Future<List<int>> fetchVehicleIds(int year, String make, String modelName);

  /// Nulo si la API no devuelve registro para el id.
  Future<SafetyRatingEntity?> fetchRating(int vehicleId);
}
