import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

VehicleRecordEntity _record(String atvType, double? mpg) => VehicleRecordEntity(
  vehicleClass: 'Compact Cars',
  atvType: atvType,
  combinedMpg: mpg,
);

void main() {
  group('RepresentativeVariantSelector', () {
    const selector = RepresentativeVariantSelector();

    test('elige el nombre más corto', () {
      expect(
        selector.select(['Corolla LE Hybrid', 'Corolla', 'Corolla SE']),
        'Corolla',
      );
    });

    test('en empate elige el primero', () {
      expect(selector.select(['Civic A', 'Civic B']), 'Civic A');
    });

    test('con lista vacía lanza ArgumentError', () {
      expect(() => selector.select([]), throwsArgumentError);
    });
  });

  group('ModelSummaryBuilder', () {
    const builder = ModelSummaryBuilder();

    test('combustión convierte millas por galón a km/l', () {
      final summary = builder.build(_record('', 34));
      expect(summary.powertrain, Powertrain.combustion);
      expect(summary.vehicleClass, 'Compact Cars');
      expect(
        summary.combinedKmPerLiter,
        closeTo(34 * UnitsConfig.milesPerGallonToKilometersPerLiter, 1e-9),
      );
    });

    test('FFV, diesel e híbrido son combustión', () {
      for (final type in ['FFV', 'Diesel', 'Hybrid']) {
        expect(
          builder.build(_record(type, 20)).powertrain,
          Powertrain.combustion,
        );
      }
    });

    test('eléctrico no tiene km/l', () {
      final summary = builder.build(_record('EV', 130));
      expect(summary.powertrain, Powertrain.electric);
      expect(summary.combinedKmPerLiter, isNull);
    });

    test('híbrido enchufable no tiene km/l', () {
      final summary = builder.build(_record('Plug-in Hybrid', 50));
      expect(summary.powertrain, Powertrain.pluginHybrid);
      expect(summary.combinedKmPerLiter, isNull);
    });

    test('un tipo no listado es other y no tiene km/l', () {
      final summary = builder.build(_record('Hidrogeno', 60));
      expect(summary.powertrain, Powertrain.other);
      expect(summary.combinedKmPerLiter, isNull);
    });

    test('no distingue mayúsculas', () {
      expect(builder.build(_record('ev', 1)).powertrain, Powertrain.electric);
      expect(
        builder.build(_record('ffv', 1)).powertrain,
        Powertrain.combustion,
      );
    });

    test('sin consumo el km/l es nulo', () {
      expect(builder.build(_record('', null)).combinedKmPerLiter, isNull);
    });
  });

  group('SummaryKeyBuilder', () {
    const keyBuilder = SummaryKeyBuilder();

    test('normaliza marca y grupo y une con el separador', () {
      expect(
        keyBuilder.build(brand: 'Land Rover', groupName: 'F-150', year: 2020),
        'landrover|f150|2020',
      );
    });

    test('ignora mayúsculas y acentos', () {
      expect(
        keyBuilder.build(brand: 'HONDA', groupName: 'Civic', year: 2020),
        keyBuilder.build(brand: 'honda', groupName: 'CIVIC', year: 2020),
      );
    });
  });
}
