import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

double _kmPerLiter(double mpg) =>
    mpg * UnitsConfig.milesPerGallonToKilometersPerLiter;

VehicleRecordEntity _record({
  String atvType = '',
  double? city = 31,
  double? highway = 40,
  double? combined = 34.2793,
  int? cost = 1750,
}) => VehicleRecordEntity(
  vehicleClass: 'Compact Cars',
  atvType: atvType,
  combinedMpg: combined,
  cityMpg: city,
  highwayMpg: highway,
  annualFuelCostUsd: cost,
  cylinders: 4,
  displacementLiters: 2.0,
  transmission: 'Automatic (AV-S10)',
  drive: 'Front-Wheel Drive',
  fuelType: 'Regular',
  make: 'Otra marca',
  model: 'Otro modelo',
  year: 1999,
);

void main() {
  const builder = VehicleDetailBuilder();

  VehicleDetailEntity build(VehicleRecordEntity record) =>
      builder.build(record, 41213, 2020, 'Toyota', 'Corolla');

  group('VehicleDetailBuilder', () {
    test('combustión: ciudad, carretera y combinado pasan a km/l', () {
      final detail = build(_record());
      expect(detail.powertrain, Powertrain.combustion);
      expect(detail.cityKmPerLiter, closeTo(_kmPerLiter(31), 1e-9));
      expect(detail.highwayKmPerLiter, closeTo(_kmPerLiter(40), 1e-9));
      expect(detail.combinedKmPerLiter, closeTo(_kmPerLiter(34.2793), 1e-9));
      expect(detail.annualFuelCostUsd, 1750);
    });

    test('usa los datos de la opción pedida, no los del registro', () {
      final detail = build(_record());
      expect(detail.id, 41213);
      expect(detail.year, 2020);
      expect(detail.make, 'Toyota');
      expect(detail.model, 'Corolla');
    });

    test(
      'copia clase, transmisión, cilindros, litros, tracción y combustible',
      () {
        final detail = build(_record());
        expect(detail.vehicleClass, 'Compact Cars');
        expect(detail.transmission, 'Automatic (AV-S10)');
        expect(detail.cylinders, 4);
        expect(detail.displacementLiters, 2.0);
        expect(detail.drive, 'Front-Wheel Drive');
        expect(detail.fuelType, 'Regular');
      },
    );

    test('eléctrico: sin km/l y con costo anual', () {
      final detail = build(_record(atvType: 'EV', cost: 600));
      expect(detail.powertrain, Powertrain.electric);
      expect(detail.cityKmPerLiter, isNull);
      expect(detail.highwayKmPerLiter, isNull);
      expect(detail.combinedKmPerLiter, isNull);
      expect(detail.annualFuelCostUsd, 600);
    });

    test('enchufable: sin km/l y con costo anual', () {
      final detail = build(_record(atvType: 'Plug-in Hybrid', cost: 1100));
      expect(detail.powertrain, Powertrain.pluginHybrid);
      expect(detail.combinedKmPerLiter, isNull);
      expect(detail.annualFuelCostUsd, 1100);
    });

    test('hidrógeno (FCV y eFCV): sin km/l y con costo anual nulo (fuelCost08 = 0)', () {
      for (final atvType in ['FCV', 'eFCV']) {
        final detail = build(_record(atvType: atvType, cost: 0));
        expect(detail.powertrain, Powertrain.fuelCell, reason: atvType);
        expect(detail.cityKmPerLiter, isNull, reason: atvType);
        expect(detail.combinedKmPerLiter, isNull, reason: atvType);
        expect(detail.annualFuelCostUsd, isNull, reason: atvType);
      }
    });

    test('Mirai (FCV, fuelCost08 0) deja el costo nulo; 1750 se conserva', () {
      final mirai = build(_record(atvType: 'FCV', cost: 0, combined: 66));
      expect(mirai.annualFuelCostUsd, isNull);
      expect(build(_record(cost: 1750)).annualFuelCostUsd, 1750);
    });

    test('un tipo no listado es other y no trae km/l', () {
      final detail = build(_record(atvType: 'Raro'));
      expect(detail.powertrain, Powertrain.other);
      expect(detail.combinedKmPerLiter, isNull);
    });

    test('los campos nulos se conservan nulos', () {
      final detail = build(
        const VehicleRecordEntity(
          vehicleClass: null,
          atvType: '',
          combinedMpg: null,
        ),
      );
      expect(detail.vehicleClass, isNull);
      expect(detail.cityKmPerLiter, isNull);
      expect(detail.highwayKmPerLiter, isNull);
      expect(detail.combinedKmPerLiter, isNull);
      expect(detail.annualFuelCostUsd, isNull);
      expect(detail.transmission, isNull);
      expect(detail.cylinders, isNull);
      expect(detail.displacementLiters, isNull);
    });

    test('el combinado se convierte tal como llega en el registro', () {
      // El mapeador del registro ya eligió comb08U sobre comb08.
      expect(
        build(_record(combined: 34)).combinedKmPerLiter,
        closeTo(_kmPerLiter(34), 1e-9),
      );
      expect(
        build(_record(combined: 34.2793)).combinedKmPerLiter,
        closeTo(_kmPerLiter(34.2793), 1e-9),
      );
    });
  });

  group('GroupSummaryBuilder con eFCV', () {
    test('eFCV (CR-V e-FCEV 2025) cuenta como hidrógeno', () {
      final summary = const GroupSummaryBuilder().build([
        const VehicleRecordEntity(
          vehicleClass: 'Small Sport Utility Vehicle 4WD',
          atvType: 'eFCV',
          combinedMpg: 39,
        ),
      ]);
      expect(summary.hasFuelCell, isTrue);
      expect(summary.minKmPerLiter, isNull);
    });
  });

  group('VehicleDetailKeyBuilder', () {
    test('une versión e id con el separador', () {
      expect(
        const VehicleDetailKeyBuilder().build(41213),
        '${VehicleSpecsConfig.vehicleDetailCacheKeyVersion}'
        '${PhotosConfig.cacheKeySeparator}41213',
      );
    });
  });
}
