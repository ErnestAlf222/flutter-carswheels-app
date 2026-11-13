import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

VehicleRecordEntity _record(
  String atvType,
  double? mpg, {
  String? vehicleClass = 'Compact Cars',
}) => VehicleRecordEntity(
  vehicleClass: vehicleClass,
  atvType: atvType,
  combinedMpg: mpg,
);

double _kmPerLiter(double mpg) =>
    mpg * UnitsConfig.milesPerGallonToKilometersPerLiter;

void main() {
  group('GroupSummaryBuilder', () {
    const builder = GroupSummaryBuilder();

    test('solo combustión: rango mínimo y máximo y cantidad de variantes', () {
      final summary = builder.build([
        _record('', 20),
        _record('Hybrid', 40),
        _record('Diesel', 30),
      ]);
      expect(summary.minKmPerLiter, closeTo(_kmPerLiter(20), 1e-9));
      expect(summary.maxKmPerLiter, closeTo(_kmPerLiter(40), 1e-9));
      expect(summary.variantCount, 3);
      expect(summary.hasElectric, isFalse);
      expect(summary.hasPluginHybrid, isFalse);
    });

    test('FFV cuenta como combustión', () {
      final summary = builder.build([_record('FFV', 19)]);
      expect(summary.minKmPerLiter, closeTo(_kmPerLiter(19), 1e-9));
    });

    test('mezcla: el rango es solo de combustión y hay eléctrico', () {
      final summary = builder.build([
        _record('', 25),
        _record('EV', 130),
        _record('', 35),
      ]);
      expect(summary.minKmPerLiter, closeTo(_kmPerLiter(25), 1e-9));
      expect(summary.maxKmPerLiter, closeTo(_kmPerLiter(35), 1e-9));
      expect(summary.hasElectric, isTrue);
    });

    test('solo eléctrico: sin rango y con hasElectric', () {
      final summary = builder.build([_record('EV', 130), _record('EV', 120)]);
      expect(summary.minKmPerLiter, isNull);
      expect(summary.maxKmPerLiter, isNull);
      expect(summary.hasElectric, isTrue);
    });

    test('plug-in hybrid: marca la etiqueta y no aporta km/l', () {
      final summary = builder.build([_record('Plug-in Hybrid', 54)]);
      expect(summary.hasPluginHybrid, isTrue);
      expect(summary.hasElectric, isFalse);
      expect(summary.minKmPerLiter, isNull);
      expect(summary.maxKmPerLiter, isNull);
    });

    test('un solo registro: mínimo igual al máximo', () {
      final summary = builder.build([_record('', 34)]);
      expect(summary.minKmPerLiter, summary.maxKmPerLiter);
      expect(summary.variantCount, 1);
    });

    test('registros sin consumo no dan rango pero cuentan como variantes', () {
      final summary = builder.build([_record('', null), _record('', null)]);
      expect(summary.minKmPerLiter, isNull);
      expect(summary.maxKmPerLiter, isNull);
      expect(summary.variantCount, 2);
    });

    test('la clase es la más frecuente', () {
      final summary = builder.build([
        _record('', 20, vehicleClass: 'Large Cars'),
        _record('', 20, vehicleClass: 'Compact Cars'),
        _record('', 20, vehicleClass: 'Compact Cars'),
      ]);
      expect(summary.vehicleClass, 'Compact Cars');
    });

    test('en empate de clase gana la de la primera variante', () {
      final summary = builder.build([
        _record('', 20, vehicleClass: 'Large Cars'),
        _record('', 20, vehicleClass: 'Compact Cars'),
      ]);
      expect(summary.vehicleClass, 'Large Cars');
    });

    test('sin ninguna clase la clase es nula', () {
      expect(
        builder.build([_record('', 20, vehicleClass: null)]).vehicleClass,
        isNull,
      );
    });

    test('un tipo no listado es other: ni km/l ni etiquetas', () {
      final summary = builder.build([_record('Hidrogeno', 60)]);
      expect(summary.minKmPerLiter, isNull);
      expect(summary.hasElectric, isFalse);
      expect(summary.hasPluginHybrid, isFalse);
      expect(summary.variantCount, 1);
    });

    test('el atvType no distingue mayúsculas', () {
      final summary = builder.build([
        _record('ev', 100),
        _record('PLUG-IN HYBRID', 50),
        _record('ffv', 20),
      ]);
      expect(summary.hasElectric, isTrue);
      expect(summary.hasPluginHybrid, isTrue);
      expect(summary.minKmPerLiter, closeTo(_kmPerLiter(20), 1e-9));
    });

    test('con lista vacía lanza ArgumentError', () {
      expect(() => builder.build([]), throwsArgumentError);
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
