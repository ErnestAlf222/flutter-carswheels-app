import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

VehicleDetailEntity _detail({
  int id = 1,
  Powertrain powertrain = Powertrain.combustion,
  double? combined,
  String? transmission,
  int? cylinders,
  double? liters,
}) => VehicleDetailEntity(
  id: id,
  year: 2020,
  make: 'Marca',
  model: 'Modelo',
  vehicleClass: null,
  powertrain: powertrain,
  transmission: transmission,
  cylinders: cylinders,
  displacementLiters: liters,
  drive: null,
  fuelType: null,
  cityKmPerLiter: null,
  highwayKmPerLiter: null,
  combinedKmPerLiter: combined,
  annualFuelCostUsd: null,
);

void main() {
  group('VersionDescriptorBuilder', () {
    const builder = VersionDescriptorBuilder(
      transmissionLabeler: TransmissionLabeler(),
    );

    test('Corolla 41213: transmisión, cilindros y litros', () {
      final detail = _detail(
        transmission: 'Automatic (AV-S10)',
        cylinders: 4,
        liters: 2.0,
      );
      expect(
        builder.describe(detail),
        'Automática CVT 10 vel. · 4 cil · 2.0 L',
      );
    });

    test('Tesla: solo transmisión', () {
      final detail = _detail(
        powertrain: Powertrain.electric,
        transmission: 'Automatic (A1)',
      );
      expect(builder.describe(detail), 'Automática 1 vel.');
    });

    test('solo las partes que existen, en orden', () {
      expect(builder.describe(_detail(cylinders: 6)), '6 cil');
      expect(
        builder.describe(_detail(cylinders: 6, liters: 3.5)),
        '6 cil · 3.5 L',
      );
      expect(
        builder.describe(_detail(transmission: 'Manual 6-spd', liters: 1.5)),
        'Manual 6 vel. · 1.5 L',
      );
    });

    test('sin ninguna parte devuelve cadena vacía', () {
      expect(builder.describe(_detail()), '');
      expect(builder.describe(_detail(transmission: '')), '');
    });
  });

  group('DefaultVersionSelector', () {
    const selector = DefaultVersionSelector();

    List<VehicleDetailEntity> combustion(List<double> values) => [
      for (final (i, v) in values.indexed) _detail(id: i, combined: v),
    ];

    test('lista vacía lanza ArgumentError', () {
      expect(() => selector.selectIndex([]), throwsArgumentError);
    });

    test('una sola versión', () {
      expect(selector.selectIndex(combustion([9])), 0);
    });

    test('cantidad impar: la del medio', () {
      expect(selector.selectIndex(combustion([9, 5, 7])), 2);
    });

    test('cantidad par: mediana inferior', () {
      expect(selector.selectIndex(combustion([9, 5, 7, 6])), 3);
    });

    test('empate: gana la posición original', () {
      // Ordenado: 5 (pos 1), 5 (pos 2), 9 (pos 0); la posición (3-1)~/2 = 1 es la 2.
      expect(selector.selectIndex(combustion([9, 5, 5])), 2);
      expect(selector.selectIndex(combustion([5, 5, 5, 5])), 1);
    });

    test('ignora los que no son de combustión o no traen consumo', () {
      final details = [
        _detail(id: 0, powertrain: Powertrain.electric, combined: null),
        _detail(id: 1, combined: 8),
        _detail(id: 2, powertrain: Powertrain.pluginHybrid, combined: 3),
        _detail(id: 3, combined: 12),
        _detail(id: 4, combined: null),
      ];
      // Candidatos: 8 (índice 1) y 12 (índice 3); mediana inferior = 8.
      expect(selector.selectIndex(details), 1);
    });

    test('solo eléctricos devuelve 0', () {
      final details = [
        _detail(powertrain: Powertrain.electric),
        _detail(id: 1, powertrain: Powertrain.fuelCell),
      ];
      expect(selector.selectIndex(details), 0);
    });

    test('grupo BMW X5 real: elige 8.4', () {
      final details = combustion([9.6, 6.4, 8.9, 7.8, 9.2, 8.4]);
      expect(selector.selectIndex(details), 5);
      expect(details[selector.selectIndex(details)].combinedKmPerLiter, 8.4);
    });
  });
}
