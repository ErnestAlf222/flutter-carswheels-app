import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_vehicle_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_catalog_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_source_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Convierte la lista de años y el catálogo de un año a JSON y de vuelta.
class MxCachePayloadMapper {
  const MxCachePayloadMapper._();

  static String sourcesToPayload(List<MxYearSourceEntity> sources) =>
      jsonEncode({
        ConueeConfig.payloadYearsKey: [
          for (final source in sources)
            {
              ConueeConfig.payloadYearKey: source.year,
              ConueeConfig.payloadResourceIdKey: source.resourceId,
            },
        ],
      });

  static List<MxYearSourceEntity> sourcesFromPayload(String payload) {
    final json = jsonDecode(payload) as Map<String, dynamic>;
    return [
      for (final item in json[ConueeConfig.payloadYearsKey] as List<dynamic>)
        MxYearSourceEntity(
          year:
              (item as Map<String, dynamic>)[ConueeConfig.payloadYearKey]
                  as int,
          resourceId: item[ConueeConfig.payloadResourceIdKey] as String,
        ),
    ];
  }

  static String catalogToPayload(MxYearCatalogEntity catalog) => jsonEncode({
    ConueeConfig.payloadYearKey: catalog.year,
    ConueeConfig.payloadRawRowCountKey: catalog.rawRowCount,
    ConueeConfig.payloadDroppedKmKey: catalog.droppedKmPerLiterCount,
    ConueeConfig.payloadVehiclesKey: [
      for (final vehicle in catalog.vehicles) _vehicleToJson(vehicle),
    ],
  });

  static MxYearCatalogEntity catalogFromPayload(String payload) {
    final json = jsonDecode(payload) as Map<String, dynamic>;
    return MxYearCatalogEntity(
      year: json[ConueeConfig.payloadYearKey] as int,
      rawRowCount: json[ConueeConfig.payloadRawRowCountKey] as int,
      droppedKmPerLiterCount: json[ConueeConfig.payloadDroppedKmKey] as int,
      vehicles: [
        for (final item
            in json[ConueeConfig.payloadVehiclesKey] as List<dynamic>)
          _vehicleFromJson(item as Map<String, dynamic>),
      ],
    );
  }

  static Map<String, dynamic> _vehicleToJson(MxVehicleEntity vehicle) => {
    ConueeConfig.payloadIdKey: vehicle.id,
    ConueeConfig.payloadBrandKey: vehicle.brand,
    ConueeConfig.payloadRawModelKey: vehicle.rawModel,
    ConueeConfig.payloadModelKey: vehicle.model,
    ConueeConfig.payloadEngineKindKey: vehicle.engineKind?.name,
    ConueeConfig.payloadFuelTypeKey: vehicle.fuelType,
    ConueeConfig.payloadCityKmKey: vehicle.cityKmPerLiter,
    ConueeConfig.payloadHighwayKmKey: vehicle.highwayKmPerLiter,
    ConueeConfig.payloadCombinedKmKey: vehicle.combinedKmPerLiter,
    ConueeConfig.payloadCityCo2Key: vehicle.cityCo2GramsPerKilometer,
    ConueeConfig.payloadHighwayCo2Key: vehicle.highwayCo2GramsPerKilometer,
    ConueeConfig.payloadCombinedCo2Key: vehicle.combinedCo2GramsPerKilometer,
    ConueeConfig.payloadCylindersKey: vehicle.cylinders,
    ConueeConfig.payloadDisplacementKey: vehicle.displacementCubicCentimeters,
    ConueeConfig.payloadTransmissionKey: vehicle.transmission,
    ConueeConfig.payloadPowerKey: vehicle.power,
    ConueeConfig.payloadTorqueKey: vehicle.torque,
  };

  static MxVehicleEntity _vehicleFromJson(Map<String, dynamic> json) {
    final kindName = json[ConueeConfig.payloadEngineKindKey] as String?;
    return MxVehicleEntity(
      id: json[ConueeConfig.payloadIdKey] as int,
      brand: json[ConueeConfig.payloadBrandKey] as String,
      rawModel: json[ConueeConfig.payloadRawModelKey] as String,
      model: json[ConueeConfig.payloadModelKey] as String,
      engineKind: kindName == null ? null : EngineKind.fromName(kindName),
      fuelType: json[ConueeConfig.payloadFuelTypeKey] as String?,
      cityKmPerLiter: _double(json[ConueeConfig.payloadCityKmKey]),
      highwayKmPerLiter: _double(json[ConueeConfig.payloadHighwayKmKey]),
      combinedKmPerLiter: _double(json[ConueeConfig.payloadCombinedKmKey]),
      cityCo2GramsPerKilometer: _double(json[ConueeConfig.payloadCityCo2Key]),
      highwayCo2GramsPerKilometer: _double(
        json[ConueeConfig.payloadHighwayCo2Key],
      ),
      combinedCo2GramsPerKilometer: _double(
        json[ConueeConfig.payloadCombinedCo2Key],
      ),
      cylinders: json[ConueeConfig.payloadCylindersKey] as String?,
      displacementCubicCentimeters:
          json[ConueeConfig.payloadDisplacementKey] as int?,
      transmission: json[ConueeConfig.payloadTransmissionKey] as String?,
      power: json[ConueeConfig.payloadPowerKey] as String?,
      torque: json[ConueeConfig.payloadTorqueKey] as String?,
    );
  }

  static double? _double(Object? value) => (value as num?)?.toDouble();
}
