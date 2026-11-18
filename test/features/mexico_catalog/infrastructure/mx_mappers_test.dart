import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/conuee_fixtures.dart';
import '../../../support/conuee_test_support.dart';

Map<String, dynamic> _row({
  String brand = 'Marca',
  String model = 'MODELO',
  String fuel = 'Gasolina',
  Object? city = 10.0,
  Object? highway = 14.0,
  Object? combined = 12.0,
  Object? co2 = 150.0,
  Object? displacement = 1998.0,
}) => {
  '_id': 1,
  'marca': brand,
  'modelo': model,
  'rendimiento_km_l_ciudad': city,
  'rendimiento_km_l_carretera': highway,
  'rendimiento_km_l_combinado': combined,
  'emisiones_co2_g_km_ciudad': co2,
  'emisiones_co2_g_km_carretera': co2,
  'emisiones_co2_g_km_combinado': co2,
  'tipo_combustible': fuel,
  'numero_cilindros': '4L',
  'desplazamiento_cm3': displacement,
  'tipo_transmision': 'Cvt',
  'potencia_maxima_hp_rpm': '190@6000',
  'torque_maximo_n_m_rpm': '242.68@1700-5000',
};

void main() {
  const mapper = MxVehicleMapper();

  group('MxVehicleMapper con filas reales', () {
    test('combustión: ADX A SPEC se limpia completo', () {
      final vehicle = conueeVehicle('ADX A SPEC');
      expect(vehicle.brand, 'Acura');
      expect(vehicle.model, 'ADX');
      expect(vehicle.rawModel, 'ADX A SPEC');
      expect(vehicle.engineKind, EngineKind.gasoline);
      expect(vehicle.combinedKmPerLiter, 16.0);
      expect(vehicle.combinedCo2GramsPerKilometer, 145.0);
      expect(vehicle.cylinders, '4 en línea');
      expect(vehicle.displacementCubicCentimeters, 1498);
      expect(vehicle.transmission, 'CVT');
      expect(vehicle.power, '190 @ 6000');
      expect(vehicle.torque, '242.68 @ 1700-5000');
    });

    test('TLX TYPE S: 6V → V6 y At → Automática', () {
      final vehicle = conueeVehicle('TLX TYPE S');
      expect(vehicle.cylinders, 'V6');
      expect(vehicle.transmission, 'Automática');
      expect(vehicle.power, '350 @ 5500');
    });

    test('eléctrico con ceros: km/l, CO2, cilindros, cilindrada y transmisión nulos', () {
      final vehicle = conueeVehicle('AVATR 11 AWD');
      expect(vehicle.engineKind, EngineKind.electric);
      expect(vehicle.cityKmPerLiter, isNull);
      expect(vehicle.highwayKmPerLiter, isNull);
      expect(vehicle.combinedKmPerLiter, isNull);
      expect(vehicle.combinedCo2GramsPerKilometer, isNull);
      expect(vehicle.cylinders, isNull);
      expect(vehicle.displacementCubicCentimeters, isNull);
      expect(vehicle.transmission, isNull);
      expect(vehicle.torque, '270');
    });

    test('ningún eléctrico del fixture conserva 0 ni 1.0 de relleno', () {
      final electrics = [
        for (final row in conueeFixtureRows)
          if (row['tipo_combustible'] == 'Eléctrico')
            mapper.map(0, row)!.vehicle,
      ];
      expect(electrics, isNotEmpty);
      for (final v in electrics) {
        for (final value in [
          v.cityKmPerLiter,
          v.highwayKmPerLiter,
          v.combinedKmPerLiter,
          v.cityCo2GramsPerKilometer,
          v.highwayCo2GramsPerKilometer,
          v.combinedCo2GramsPerKilometer,
        ]) {
          expect(value, isNot(anyOf(0.0, 1.0)), reason: v.rawModel);
        }
      }
    });

    test('un eléctrico con km/l real lo conserva', () {
      final real = conueeFixtureRows.firstWhere(
        (row) =>
            row['tipo_combustible'] == 'Eléctrico' &&
            row['rendimiento_km_l_combinado'] is double &&
            (row['rendimiento_km_l_combinado'] as double) > 1.0,
      );
      expect(
        mapper.map(0, real)!.vehicle.combinedKmPerLiter,
        real['rendimiento_km_l_combinado'],
      );
    });

    test('híbrido: conserva km/l; MHEV también', () {
      final corolla = conueeVehicle('COROLLA HIBRIDO');
      expect(corolla.engineKind, EngineKind.hybrid);
      expect(corolla.combinedKmPerLiter, isNotNull);
      expect(
        conueeVehicle('DISCOVERY SPORT MHEV').engineKind,
        EngineKind.hybrid,
      );
    });

    test('enchufables y E-Rev: km/l nulo y CO2 conservado', () {
      for (final model in [
        'OUTLANDER PHEV SE PLUS',
        'CORSAIR 2.5L PHEV **',
        'F PACE PHEV',
        'AVATR 07 (REEV) AWD',
        'JETOUR T2 I-DM 1.5T PHEV',
        'X-TRAIL E-POWER E-REV',
        'SONG PRO DM-I',
      ]) {
        final vehicle = conueeVehicle(model);
        expect(vehicle.engineKind, EngineKind.pluginHybrid, reason: model);
        expect(vehicle.cityKmPerLiter, isNull, reason: model);
        expect(vehicle.combinedKmPerLiter, isNull, reason: model);
        expect(vehicle.combinedCo2GramsPerKilometer, isNotNull, reason: model);
      }
    });

    test('grafías raras de cilindros y transmisión de los fixtures', () {
      final labels = {
        for (final row in conueeFixtureRows)
          mapper.map(0, row)!.vehicle.cylinders,
      };
      expect(labels, containsAll(['4 en línea', 'V6']));
      expect(labels, contains(isNull));
      final transmissions = {
        for (final row in conueeFixtureRows)
          mapper.map(0, row)!.vehicle.transmission,
      };
      expect(transmissions, contains('Automática de 6 velocidades'));
      expect(transmissions, contains('Dtc'));
    });
  });

  group('MxVehicleMapper reglas', () {
    test('km/l fuera del rango plausible es nulo y se cuenta', () {
      final tooHigh = mapper.map(0, _row(combined: 55.0))!;
      expect(tooHigh.vehicle.combinedKmPerLiter, isNull);
      expect(tooHigh.vehicle.cityKmPerLiter, 10.0);
      expect(tooHigh.droppedKmPerLiter, isTrue);
      final zero = mapper.map(0, _row(city: 0.0))!;
      expect(zero.vehicle.cityKmPerLiter, isNull);
      expect(zero.droppedKmPerLiter, isTrue);
      expect(mapper.map(0, _row())!.droppedKmPerLiter, isFalse);
    });

    test('los límites del rango se conservan', () {
      final vehicle = mapper
          .map(
            0,
            _row(
              city: ConueeConfig.minPlausibleKmPerLiter,
              combined: ConueeConfig.maxPlausibleKmPerLiter,
            ),
          )!
          .vehicle;
      expect(vehicle.cityKmPerLiter, ConueeConfig.minPlausibleKmPerLiter);
      expect(vehicle.combinedKmPerLiter, ConueeConfig.maxPlausibleKmPerLiter);
    });

    test('dato ausente es nulo y números en texto se leen', () {
      final vehicle = mapper
          .map(
            0,
            _row(city: null, combined: '12.5', co2: null, displacement: null),
          )!
          .vehicle;
      expect(vehicle.cityKmPerLiter, isNull);
      expect(vehicle.combinedKmPerLiter, 12.5);
      expect(vehicle.combinedCo2GramsPerKilometer, isNull);
      expect(vehicle.displacementCubicCentimeters, isNull);
    });

    test('combustible desconocido: engineKind nulo y combustible tal cual', () {
      final vehicle = mapper.map(0, _row(fuel: 'Hidrógeno'))!.vehicle;
      expect(vehicle.engineKind, isNull);
      expect(vehicle.fuelType, 'Hidrógeno');
      expect(vehicle.combinedKmPerLiter, 12.0);
    });

    test('sin marca o sin modelo no hay fila', () {
      expect(mapper.map(0, _row(brand: ' ')), isNull);
      expect(mapper.map(0, _row(model: '')), isNull);
    });
  });

  group('MxYearCatalogMapper', () {
    const catalogMapper = MxYearCatalogMapper();

    test('colapsa filas idénticas ignorando _id', () {
      final first = Map<String, dynamic>.of(conueeRow('TLX TYPE S'));
      final second = {...first, '_id': 9999};
      final other = {
        ...first,
        '_id': 10000,
        'rendimiento_km_l_combinado': 11.0,
      };
      final catalog = catalogMapper.toEntity(2025, [first, second, other]);
      expect(catalog.rawRowCount, 3);
      // Mismo marca+modelo con datos distintos se conserva como otra versión.
      expect(catalog.vehicles.map((v) => v.rawModel), [
        'TLX TYPE S',
        'TLX TYPE S',
      ]);
      expect(catalog.vehicles.map((v) => v.id), [0, 1]);
    });

    test('el par idéntico real de los fixtures se colapsa', () {
      final catalog = catalogMapper.toEntity(2025, conueeFixtureRows);
      expect(catalog.rawRowCount, conueeFixtureRows.length);
      expect(catalog.vehicles.length, conueeFixtureRows.length - 1);
    });

    test('cuenta las filas con km/l descartado', () {
      final catalog = catalogMapper.toEntity(2025, [
        _row(model: 'A', combined: 99.0),
        _row(model: 'B'),
      ]);
      expect(catalog.droppedKmPerLiterCount, 1);
    });
  });

  group('MxCachePayloadMapper', () {
    test('el catálogo hace viaje de ida y vuelta por JSON', () {
      final catalog = const MxYearCatalogMapper().toEntity(
        2026,
        conueeFixtureRows,
      );
      final back = MxCachePayloadMapper.catalogFromPayload(
        MxCachePayloadMapper.catalogToPayload(catalog),
      );
      expect(back, catalog);
    });

    test('la lista de años hace viaje de ida y vuelta', () {
      const sources = [
        MxYearSourceEntity(year: 2026, resourceId: 'b'),
        MxYearSourceEntity(year: 2025, resourceId: 'a'),
      ];
      expect(
        MxCachePayloadMapper.sourcesFromPayload(
          MxCachePayloadMapper.sourcesToPayload(sources),
        ),
        sources,
      );
    });
  });
}
