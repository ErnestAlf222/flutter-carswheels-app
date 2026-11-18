import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';

import 'conuee_fixtures.dart';

/// Primera fila real de los fixtures con ese modelo; falla si no existe.
Map<String, dynamic> conueeRow(String model) =>
    conueeFixtureRows.firstWhere((row) => row['modelo'] == model);

/// Fila real del fixture ya limpia con el mapper por defecto.
MxVehicleEntity conueeVehicle(String model) {
  final row = conueeRow(model);
  return const MxVehicleMapper().map(0, row)!.vehicle;
}

/// Fila limpia mínima a partir de la marca y el nombre original.
MxVehicleEntity mxVehicle(String brand, String rawModel, {int id = 0}) =>
    MxVehicleEntity(
      id: id,
      brand: brand,
      rawModel: rawModel,
      model: const MxModelNameCleaner().clean(brand, rawModel),
    );

/// Catálogo de un año con las filas dadas.
MxYearCatalogEntity mxCatalog(int year, List<MxVehicleEntity> vehicles) =>
    MxYearCatalogEntity(
      year: year,
      vehicles: vehicles,
      rawRowCount: vehicles.length,
      droppedKmPerLiterCount: 0,
    );
