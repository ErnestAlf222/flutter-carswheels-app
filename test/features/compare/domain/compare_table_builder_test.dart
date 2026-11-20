import 'package:flutter_test/flutter_test.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

const CompareTableBuilder _builder = CompareTableBuilder();

List<CompareTableSectionEntity> _build(
  List<CompareVehicleDetailEntity?> columns, {
  String market = MarketConfig.unitedStatesCode,
}) => _builder.build(marketCode: market, columns: columns);

CompareTableRowEntity? _row(
  List<CompareTableSectionEntity> sections,
  CompareRowKind kind,
) => sections
    .expand((section) => section.rows)
    .where((row) => row.kind == kind)
    .firstOrNull;

List<String?> _texts(CompareTableRowEntity row) => [
  for (final cell in row.cells) cell?.text,
];

List<bool?> _best(CompareTableRowEntity row) => [
  for (final cell in row.cells) cell?.isBest,
];

void main() {
  group('filas ocultas y "—"', () {
    test('la fila no aparece si ningún vehículo tiene el dato', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(fuelLabel: 'Gasolina'),
        CompareVehicleDetailEntity(fuelLabel: 'Diésel'),
      ]);
      expect(_row(sections, CompareRowKind.combinedConsumption), isNull);
      expect(_row(sections, CompareRowKind.annualCost), isNull);
      expect(_row(sections, CompareRowKind.fuel), isNotNull);
    });

    test('una sección sin filas no aparece', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(fuelLabel: 'Gasolina'),
        CompareVehicleDetailEntity(fuelLabel: 'Diésel'),
      ]);
      expect(sections.map((section) => section.title), [
        AppTexts.compareSectionEngine,
      ]);
    });

    test('sin ningún dato no hay secciones', () {
      expect(
        _build(const [
          CompareVehicleDetailEntity(),
          CompareVehicleDetailEntity(),
        ]),
        isEmpty,
      );
    });

    test('si falta en un vehículo su celda es "—", nunca cero', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(combinedKmPerLiter: 14.6),
        CompareVehicleDetailEntity(),
      ]);
      expect(_texts(_row(sections, CompareRowKind.combinedConsumption)!), [
        '14.6',
        AppTexts.noDataLabel,
      ]);
    });

    test('un eléctrico sin km/l muestra "—" junto a uno de combustión', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(
          engineKind: CompareEngineKind.combustion,
          combinedKmPerLiter: 15.0,
        ),
        CompareVehicleDetailEntity(engineKind: CompareEngineKind.electric),
      ]);
      expect(_texts(_row(sections, CompareRowKind.combinedConsumption)!), [
        '15.0',
        AppTexts.noDataLabel,
      ]);
      expect(_texts(_row(sections, CompareRowKind.engine)!), [
        AppTexts.compareEngineCombustionLabel,
        AppTexts.electricLabel,
      ]);
    });

    test('la columna que carga o falló no tiene celda ni cuenta', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(combinedKmPerLiter: 12.0),
        null,
        CompareVehicleDetailEntity(),
      ]);
      final row = _row(sections, CompareRowKind.combinedConsumption)!;
      expect(row.cells[1], isNull);
      expect(_texts(row), ['12.0', null, AppTexts.noDataLabel]);
    });

    test('si solo hay columnas sin cargar no hay filas', () {
      expect(_build(const [null, null]), isEmpty);
    });
  });

  group('mejor valor', () {
    test('consumo: gana el mayor', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(combinedKmPerLiter: 12.0),
        CompareVehicleDetailEntity(combinedKmPerLiter: 18.5),
        CompareVehicleDetailEntity(combinedKmPerLiter: 15.0),
      ]);
      expect(_best(_row(sections, CompareRowKind.combinedConsumption)!), [
        false,
        true,
        false,
      ]);
    });

    test('CO₂ y costo: gana el menor, y un CO₂ de 0 es válido', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(
          co2GramsPerKilometer: 0,
          annualFuelCostUsd: 600,
        ),
        CompareVehicleDetailEntity(
          co2GramsPerKilometer: 150,
          annualFuelCostUsd: 1750,
        ),
      ]);
      expect(_best(_row(sections, CompareRowKind.co2)!), [true, false]);
      expect(_best(_row(sections, CompareRowKind.annualCost)!), [true, false]);
    });

    test('estrellas NHTSA: gana el mayor', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(safetyStars: 4),
        CompareVehicleDetailEntity(safetyStars: 5),
      ]);
      expect(_best(_row(sections, CompareRowKind.safety)!), [false, true]);
    });

    test('con empate en el mejor valor se resaltan todos los empatados', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(combinedKmPerLiter: 18.0),
        CompareVehicleDetailEntity(combinedKmPerLiter: 18.0),
        CompareVehicleDetailEntity(combinedKmPerLiter: 10.0),
      ]);
      expect(_best(_row(sections, CompareRowKind.combinedConsumption)!), [
        true,
        true,
        false,
      ]);
    });

    test('con un solo dato no se resalta', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(combinedKmPerLiter: 18.0),
        CompareVehicleDetailEntity(),
      ]);
      expect(_best(_row(sections, CompareRowKind.combinedConsumption)!), [
        false,
        false,
      ]);
    });

    test('con todos los valores iguales no se resalta', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(safetyStars: 5),
        CompareVehicleDetailEntity(safetyStars: 5),
        CompareVehicleDetailEntity(safetyStars: 5),
      ]);
      expect(_best(_row(sections, CompareRowKind.safety)!), [
        false,
        false,
        false,
      ]);
    });

    test('valores que se muestran igual se consideran iguales', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(combinedKmPerLiter: 14.61),
        CompareVehicleDetailEntity(combinedKmPerLiter: 14.64),
      ]);
      expect(_best(_row(sections, CompareRowKind.combinedConsumption)!), [
        false,
        false,
      ]);
    });

    test('una columna sin cargar no entra al cálculo del mejor valor', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(combinedKmPerLiter: 10.0),
        null,
        CompareVehicleDetailEntity(combinedKmPerLiter: 20.0),
      ]);
      expect(_best(_row(sections, CompareRowKind.combinedConsumption)!), [
        false,
        null,
        true,
      ]);
    });

    test('las filas sin criterio nunca se resaltan', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(
          engineKind: CompareEngineKind.electric,
          fuelLabel: 'Gasolina',
          cylindersLabel: '4 cil',
          transmissionLabel: 'Automática',
          driveLabel: 'Tracción delantera',
          classLabel: 'Compacto',
        ),
        CompareVehicleDetailEntity(
          engineKind: CompareEngineKind.combustion,
          fuelLabel: 'Diésel',
          cylindersLabel: '6 cil',
          transmissionLabel: 'Manual',
          driveLabel: 'Tracción total',
          classLabel: 'SUV',
        ),
      ]);
      for (final kind in [
        CompareRowKind.engine,
        CompareRowKind.fuel,
        CompareRowKind.cylinders,
        CompareRowKind.transmission,
        CompareRowKind.drive,
        CompareRowKind.vehicleClass,
      ]) {
        expect(_best(_row(sections, kind)!), [false, false], reason: '$kind');
      }
    });

    test('potencia, torque y compresión de México no se resaltan', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(
          powerLabel: '190 hp',
          torqueLabel: '250 N·m',
          compressionLabel: '10.5:1',
        ),
        CompareVehicleDetailEntity(
          powerLabel: '300 hp',
          torqueLabel: '400 N·m',
          compressionLabel: '9.0:1',
        ),
      ], market: MarketConfig.mexicoCode);
      for (final kind in [
        CompareRowKind.power,
        CompareRowKind.torque,
        CompareRowKind.compression,
      ]) {
        expect(_best(_row(sections, kind)!), [false, false], reason: '$kind');
      }
    });
  });

  group('formato', () {
    test(
      'consumo con un decimal, CO₂ en g/km, costo con miles y estrellas',
      () {
        final sections = _build(const [
          CompareVehicleDetailEntity(
            combinedKmPerLiter: 14.64,
            cityKmPerLiter: 12.0,
            highwayKmPerLiter: 17.2,
            co2GramsPerKilometer: 151.4,
            annualFuelCostUsd: 1750,
            safetyStars: 5,
          ),
          CompareVehicleDetailEntity(),
        ]);
        expect(
          _texts(_row(sections, CompareRowKind.combinedConsumption)!)[0],
          '14.6',
        );
        expect(
          _texts(_row(sections, CompareRowKind.cityConsumption)!)[0],
          '12.0',
        );
        expect(
          _texts(_row(sections, CompareRowKind.highwayConsumption)!)[0],
          '17.2',
        );
        expect(_texts(_row(sections, CompareRowKind.co2)!)[0], '151 g/km');
        expect(
          _texts(_row(sections, CompareRowKind.annualCost)!)[0],
          r'$1,750',
        );
        expect(
          _texts(_row(sections, CompareRowKind.safety)!)[0],
          AppTexts.compareStarsValue(5),
        );
      },
    );

    test('las secciones salen en orden con su título', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(
          combinedKmPerLiter: 14.0,
          fuelLabel: 'Gasolina',
          safetyStars: 4,
        ),
        CompareVehicleDetailEntity(),
      ]);
      expect(sections.map((section) => section.title), [
        AppTexts.compareSectionConsumption,
        AppTexts.compareSectionEngine,
        AppTexts.compareSectionSafetyCost,
      ]);
    });
  });

  group('reglas de México', () {
    const mexican = CompareVehicleDetailEntity(
      engineKind: CompareEngineKind.combustion,
      combinedKmPerLiter: 14.0,
      co2GramsPerKilometer: 160,
      fuelLabel: 'Gasolina',
      cylindersLabel: '4',
      transmissionLabel: 'Automática',
      powerLabel: '190 hp',
      torqueLabel: '250 N·m',
      compressionLabel: '10.5:1',
    );

    test('no hay filas de NHTSA, costo, clase ni tracción', () {
      final sections = _build(const [
        CompareVehicleDetailEntity(
          combinedKmPerLiter: 14.0,
          safetyStars: 5,
          annualFuelCostUsd: 900,
          classLabel: 'SUV',
          driveLabel: 'Tracción total',
        ),
        mexican,
      ], market: MarketConfig.mexicoCode);
      for (final kind in [
        CompareRowKind.safety,
        CompareRowKind.annualCost,
        CompareRowKind.vehicleClass,
        CompareRowKind.drive,
      ]) {
        expect(_row(sections, kind), isNull, reason: '$kind');
      }
      expect(
        sections.map((section) => section.title),
        isNot(contains(AppTexts.compareSectionSafetyCost)),
      );
    });

    test('potencia, torque y compresión aparecen, con "—" donde falten', () {
      final sections = _build(const [
        mexican,
        CompareVehicleDetailEntity(powerLabel: '120 hp'),
      ], market: MarketConfig.mexicoCode);
      expect(_texts(_row(sections, CompareRowKind.power)!), [
        '190 hp',
        '120 hp',
      ]);
      expect(_texts(_row(sections, CompareRowKind.torque)!), [
        '250 N·m',
        AppTexts.noDataLabel,
      ]);
      expect(_texts(_row(sections, CompareRowKind.compression)!), [
        '10.5:1',
        AppTexts.noDataLabel,
      ]);
    });

    test('en EE. UU. no aparecen potencia, torque ni compresión', () {
      final sections = _build(const [mexican, mexican]);
      expect(_row(sections, CompareRowKind.power), isNull);
      expect(_row(sections, CompareRowKind.torque), isNull);
      expect(_row(sections, CompareRowKind.compression), isNull);
    });
  });
}
