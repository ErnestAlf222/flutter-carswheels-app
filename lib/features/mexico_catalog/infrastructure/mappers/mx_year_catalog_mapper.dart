import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_vehicle_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_catalog_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/infrastructure/mappers/mx_vehicle_mapper.dart';

/// Convierte las filas crudas de un año en su catálogo limpio.
class MxYearCatalogMapper {
  const MxYearCatalogMapper({this.vehicleMapper = const MxVehicleMapper()});

  final MxVehicleMapper vehicleMapper;

  /// Colapsa las filas idénticas (ignorando _id) y limpia cada una.
  MxYearCatalogEntity toEntity(int year, List<Map<String, dynamic>> rows) {
    final unique = collapse(rows);
    final vehicles = <MxVehicleEntity>[];
    int dropped = 0;
    for (final row in unique) {
      final mapped = vehicleMapper.map(vehicles.length, row);
      if (mapped == null) continue;
      vehicles.add(mapped.vehicle);
      if (mapped.droppedKmPerLiter) dropped++;
    }
    return MxYearCatalogEntity(
      year: year,
      vehicles: vehicles,
      rawRowCount: rows.length,
      droppedKmPerLiterCount: dropped,
    );
  }

  /// Filas sin repetir, en su orden original; un mismo modelo con datos
  /// distintos se conserva como versiones diferentes.
  static List<Map<String, dynamic>> collapse(List<Map<String, dynamic>> rows) {
    final seen = <String>{};
    return [
      for (final row in rows)
        if (seen.add(_signature(row))) row,
    ];
  }

  static String _signature(Map<String, dynamic> row) => jsonEncode({
    for (final entry in row.entries)
      if (entry.key != ConueeConfig.rowIdKey) entry.key: entry.value,
  });
}
