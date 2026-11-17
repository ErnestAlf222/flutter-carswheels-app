import 'package:cars_wheels_app/features/safety/domain/entities/recall_entity.dart';

/// Recalls de NHTSA y la lista de modelos de vPIC.
abstract class NhtsaRecallsDatasource {
  /// Lista vacía si NHTSA no tiene recalls para el nombre dado.
  Future<List<RecallEntity>> fetchRecalls(int year, String make, String model);

  /// Nombres de modelo que vPIC registra para la marca y el año.
  Future<List<String>> fetchVpicModelNames(int year, String make);
}
