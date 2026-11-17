import 'package:cars_wheels_app/core/core.dart';

/// Lista de resultados de una respuesta de NHTSA o vPIC.
class NhtsaResultsModel {
  const NhtsaResultsModel(this.results);

  /// La clave de la lista cambia entre servicios ("Results" o "results").
  factory NhtsaResultsModel.fromJson(Object? data, String resultsKey) {
    if (data is! Map<String, dynamic>) {
      throw const ParsingFailure('Respuesta de NHTSA sin forma de objeto');
    }
    final list = data[resultsKey];
    if (list is! List<dynamic>) {
      throw const ParsingFailure('Respuesta de NHTSA sin lista de resultados');
    }
    return NhtsaResultsModel([
      for (final item in list)
        if (item is Map<String, dynamic>) item,
    ]);
  }

  final List<Map<String, dynamic>> results;
}
