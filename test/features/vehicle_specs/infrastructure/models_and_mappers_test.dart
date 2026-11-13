import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

// Registros reales de FuelEconomy (campos relevantes).
const Map<String, dynamic> _toyota4Runner = {
  'VClass': 'Standard Sport Utility Vehicle 2WD',
  'atvType': '',
  'comb08': '17',
  'comb08U': '17.4613',
};
const Map<String, dynamic> _tesla = {
  'VClass': 'Midsize Cars',
  'atvType': 'EV',
  'comb08': '130',
  'comb08U': '130.2464',
};

void main() {
  group('FuelEconomyOptionsModel', () {
    test('lee una lista de opciones', () {
      final model = FuelEconomyOptionsModel.fromJson({
        'menuItem': [
          {'text': 'Auto (AV-S10), 4 cyl, 2.0 L', 'value': '41213'},
          {'text': 'Man 6-spd, 4 cyl, 2.0 L', 'value': '41214'},
        ],
      });
      expect(model.ids, [41213, 41214]);
    });

    test('lee un único objeto', () {
      final model = FuelEconomyOptionsModel.fromJson({
        'menuItem': {'text': 'Auto', 'value': '31873'},
      });
      expect(model.ids, [31873]);
    });

    test('menuItem ausente da lista vacía', () {
      expect(
        FuelEconomyOptionsModel.fromJson(<String, dynamic>{}).ids,
        isEmpty,
      );
    });

    test('ignora valores no numéricos o ausentes', () {
      final model = FuelEconomyOptionsModel.fromJson({
        'menuItem': [
          {'text': 'a', 'value': 'abc'},
          {'text': 'b'},
          {'text': 'c', 'value': '7'},
        ],
      });
      expect(model.ids, [7]);
    });

    test('una raíz que no es objeto falla', () {
      expect(
        () => FuelEconomyOptionsModel.fromJson(<dynamic>[]),
        throwsA(isA<ParsingFailure>()),
      );
    });

    test('un item que no es objeto falla', () {
      expect(
        () => FuelEconomyOptionsModel.fromJson({
          'menuItem': ['41213'],
        }),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });

  group('FuelEconomyVehicleModel', () {
    test('lee los campos en texto', () {
      final model = FuelEconomyVehicleModel.fromJson(_toyota4Runner);
      expect(model.vehicleClass, 'Standard Sport Utility Vehicle 2WD');
      expect(model.atvType, '');
      expect(model.combinedMpg, '17');
      expect(model.combinedMpgPrecise, '17.4613');
    });

    test('tolera campos ausentes o vacíos', () {
      final model = FuelEconomyVehicleModel.fromJson({'VClass': ''});
      expect(model.vehicleClass, isNull);
      expect(model.atvType, '');
      expect(model.combinedMpg, isNull);
      expect(model.combinedMpgPrecise, isNull);
    });

    test('una raíz que no es objeto falla', () {
      expect(
        () => FuelEconomyVehicleModel.fromJson('texto'),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });

  group('VehicleRecordMapper', () {
    VehicleRecordEntity map(Map<String, dynamic> json) =>
        VehicleRecordMapper.toEntity(FuelEconomyVehicleModel.fromJson(json));

    test('usa comb08U cuando es mayor que 0', () {
      expect(map(_toyota4Runner).combinedMpg, 17.4613);
    });

    test('usa comb08 cuando comb08U falta o es 0', () {
      expect(map({'comb08': '34', 'comb08U': '0'}).combinedMpg, 34);
      expect(map({'comb08': '34'}).combinedMpg, 34);
    });

    test('es nulo si ambos faltan o son 0', () {
      expect(map({'comb08': '0', 'comb08U': '0'}).combinedMpg, isNull);
      expect(map(<String, dynamic>{}).combinedMpg, isNull);
    });

    test('conserva clase y atvType', () {
      final entity = map(_tesla);
      expect(entity.vehicleClass, 'Midsize Cars');
      expect(entity.atvType, 'EV');
    });
  });

  group('CachedSummaryMapper', () {
    final entity = CachedSummaryEntity(
      summary: const ModelSummaryEntity(
        vehicleClass: 'Compact Cars',
        powertrain: Powertrain.pluginHybrid,
        combinedKmPerLiter: null,
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    );

    test('ida y vuelta conserva la entidad', () {
      final model = CachedSummaryMapper.toModel('clave', entity);
      expect(model.key, 'clave');
      expect(model.powertrain, 'pluginHybrid');
      expect(CachedSummaryMapper.toEntity(model), entity);
    });

    test('una motorización desconocida se lee como other', () {
      final model = ModelSummaryCacheModel(
        key: 'k',
        vehicleClass: null,
        powertrain: 'inventado',
        combinedKmPerLiter: 12.5,
        savedAtMillis: 0,
      );
      final restored = CachedSummaryMapper.toEntity(model);
      expect(restored.summary.powertrain, Powertrain.other);
      expect(restored.summary.combinedKmPerLiter, 12.5);
    });
  });
}
