import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/vehicle_record_fixtures.dart';

class _MockDio extends Mock implements Dio {}

Response<Object?> _response(Object? data) => Response<Object?>(
  data: data,
  requestOptions: RequestOptions(path: '/x'),
);

VehicleRecordEntity _map(Map<String, dynamic> json) =>
    VehicleRecordMapper.toEntity(FuelEconomyVehicleModel.fromJson(json));

void main() {
  group('FuelEconomyOptionsModel con texto', () {
    test('lee id y texto de una lista (Corolla 2020)', () {
      final model = FuelEconomyOptionsModel.fromJson({
        'menuItem': [
          {'text': 'Auto (AV-S10), 4 cyl, 2.0 L', 'value': '41213'},
          {'text': 'Man 6-spd, 4 cyl, 2.0 L', 'value': '41215'},
        ],
      });
      expect(model.items, [
        (id: 41213, text: 'Auto (AV-S10), 4 cyl, 2.0 L'),
        (id: 41215, text: 'Man 6-spd, 4 cyl, 2.0 L'),
      ]);
      expect(model.ids, [41213, 41215]);
    });

    test('lee un único objeto', () {
      final model = FuelEconomyOptionsModel.fromJson({
        'menuItem': {'text': 'Auto', 'value': '31873'},
      });
      expect(model.items, [(id: 31873, text: 'Auto')]);
    });

    test('ausente da lista vacía', () {
      expect(
        FuelEconomyOptionsModel.fromJson(<String, dynamic>{}).items,
        isEmpty,
      );
    });

    test('sin texto usa cadena vacía', () {
      final model = FuelEconomyOptionsModel.fromJson({
        'menuItem': [
          {'value': '7'},
        ],
      });
      expect(model.items, [(id: 7, text: '')]);
    });

    test('un id no numérico se ignora', () {
      final model = FuelEconomyOptionsModel.fromJson({
        'menuItem': [
          {'text': 'a', 'value': 'abc'},
          {'text': 'b', 'value': '8'},
        ],
      });
      expect(model.items, [(id: 8, text: 'b')]);
    });

    test('el texto se conserva tal como llega', () {
      final model = FuelEconomyOptionsModel.fromJson({
        'menuItem': [
          {'text': ' Auto (S8), 6 cyl ', 'value': '1'},
        ],
      });
      expect(model.items.single.text, ' Auto (S8), 6 cyl ');
    });
  });

  group('VehicleOptionMapper', () {
    test('convierte los items en entidades en el mismo orden', () {
      final entities = VehicleOptionMapper.toEntities(
        FuelEconomyOptionsModel.fromJson({
          'menuItem': [
            {'text': 'b', 'value': '2'},
            {'text': 'a', 'value': '1'},
          ],
        }),
      );
      expect(entities, const [
        VehicleOptionEntity(id: 2, text: 'b'),
        VehicleOptionEntity(id: 1, text: 'a'),
      ]);
    });
  });

  group(
    'FuelEconomyVehicleModel y VehicleRecordMapper con registros reales',
    () {
      test('Corolla 41213: todos los campos', () {
        expect(
          _map(corolla41213Json),
          const VehicleRecordEntity(
            vehicleClass: 'Compact Cars',
            atvType: '',
            combinedMpg: 34.2793,
            cityMpg: 31,
            highwayMpg: 40,
            annualFuelCostUsd: 1750,
            cylinders: 4,
            displacementLiters: 2.0,
            transmission: 'Automatic (AV-S10)',
            drive: 'Front-Wheel Drive',
            fuelType: 'Regular',
            make: 'Toyota',
            model: 'Corolla',
            year: 2020,
          ),
        );
      });

      test('Tesla: cilindros y litros vacíos dan nulo', () {
        final entity = _map(tesla42274Json);
        expect(entity.cylinders, isNull);
        expect(entity.displacementLiters, isNull);
        expect(entity.atvType, 'EV');
        expect(entity.annualFuelCostUsd, 600);
        expect(entity.fuelType, 'Electricity');
      });

      test('Prius Prime y Mirai conservan sus campos', () {
        expect(_map(priusPrime41489Json).displacementLiters, 1.8);
        expect(_map(priusPrime41489Json).atvType, 'Plug-in Hybrid');
        expect(_map(mirai47538Json).atvType, 'FCV');
        expect(_map(mirai47538Json).annualFuelCostUsd, 0);
      });

      test('campos ausentes dan nulo sin lanzar', () {
        final entity = _map(<String, dynamic>{});
        expect(entity.cityMpg, isNull);
        expect(entity.highwayMpg, isNull);
        expect(entity.annualFuelCostUsd, isNull);
        expect(entity.cylinders, isNull);
        expect(entity.displacementLiters, isNull);
        expect(entity.transmission, isNull);
        expect(entity.drive, isNull);
        expect(entity.fuelType, isNull);
        expect(entity.make, isNull);
        expect(entity.model, isNull);
        expect(entity.year, isNull);
      });

      test('enteros y decimales mal formados dan nulo sin lanzar', () {
        final entity = _map({
          'city08': 'abc',
          'highway08': '0',
          'fuelCost08': '12x',
          'cylinders': '4.5',
          'displ': 'dos',
          'year': '20-20',
        });
        expect(entity.cityMpg, isNull);
        expect(entity.highwayMpg, isNull);
        expect(entity.annualFuelCostUsd, isNull);
        expect(entity.cylinders, isNull);
        expect(entity.displacementLiters, isNull);
        expect(entity.year, isNull);
      });

      test('los textos se recortan y los vacíos dan nulo', () {
        final entity = _map({'trany': '  Manual 6-spd ', 'drive': '   '});
        expect(entity.transmission, 'Manual 6-spd');
        expect(entity.drive, isNull);
      });
    },
  );

  group('CachedDetailMapper', () {
    final entity = CachedDetailEntity(
      detail: const VehicleDetailEntity(
        id: 41213,
        year: 2020,
        make: 'Toyota',
        model: 'Corolla',
        vehicleClass: 'Compact Cars',
        powertrain: Powertrain.pluginHybrid,
        transmission: 'Automatic (AV-S10)',
        cylinders: 4,
        displacementLiters: 2.0,
        drive: 'Front-Wheel Drive',
        fuelType: 'Regular',
        cityKmPerLiter: 13.1,
        highwayKmPerLiter: 17,
        combinedKmPerLiter: 14.5,
        annualFuelCostUsd: 1750,
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    );

    test('ida y vuelta conserva la entidad', () {
      final model = CachedDetailMapper.toModel('v1|41213', entity);
      expect(model.key, 'v1|41213');
      expect(model.vehicleId, 41213);
      expect(model.powertrain, 'pluginHybrid');
      expect(model.savedAtMillis, 1700000000000);
      expect(CachedDetailMapper.toEntity(model), entity);
    });

    test('conserva los campos nulos', () {
      final empty = CachedDetailEntity(
        detail: const VehicleDetailEntity(
          id: 1,
          year: 2020,
          make: 'Tesla',
          model: 'Model 3',
          vehicleClass: null,
          powertrain: Powertrain.electric,
          transmission: null,
          cylinders: null,
          displacementLiters: null,
          drive: null,
          fuelType: null,
          cityKmPerLiter: null,
          highwayKmPerLiter: null,
          combinedKmPerLiter: null,
          annualFuelCostUsd: null,
        ),
        savedAt: entity.savedAt,
      );
      expect(
        CachedDetailMapper.toEntity(CachedDetailMapper.toModel('k', empty)),
        empty,
      );
    });

    test('una motorización desconocida guardada se lee como other', () {
      final model = CachedDetailMapper.toModel('k', entity);
      final unknown = VehicleDetailCacheModel(
        key: model.key,
        vehicleId: model.vehicleId,
        year: model.year,
        make: model.make,
        model: model.model,
        vehicleClass: null,
        powertrain: 'inexistente',
        transmission: null,
        cylinders: null,
        displacementLiters: null,
        drive: null,
        fuelType: null,
        cityKmPerLiter: null,
        highwayKmPerLiter: null,
        combinedKmPerLiter: null,
        annualFuelCostUsd: null,
        savedAtMillis: 0,
      );
      expect(
        CachedDetailMapper.toEntity(unknown).detail.powertrain,
        Powertrain.other,
      );
    });
  });

  group('FuelEconomyVehicleSpecsDatasource: opciones y detalle', () {
    late _MockDio dio;
    late ConcurrencyLimitedQueue queue;
    late FuelEconomyVehicleSpecsDatasource datasource;

    void stubGet(Object? data) {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response(data));
    }

    setUp(() {
      dio = _MockDio();
      queue = ConcurrencyLimitedQueue(maxConcurrent: 2);
      datasource = FuelEconomyVehicleSpecsDatasource(dio: dio, queue: queue);
    });

    test('fetchOptions pide la ruta con year, make y model', () async {
      stubGet({
        'menuItem': [
          {'text': 'Auto (S10), 6 cyl, 3.5 L, Turbo', 'value': '42171'},
        ],
      });
      final options = await datasource.fetchOptions(
        2020,
        'Ford',
        'F150 Pickup 2WD',
      );
      expect(options, const [
        VehicleOptionEntity(id: 42171, text: 'Auto (S10), 6 cyl, 3.5 L, Turbo'),
      ]);
      verify(
        () => dio.get<Object?>(
          VehicleSpecsConfig.optionsPath,
          queryParameters: {
            FuelEconomyConfig.yearQueryParameter: 2020,
            FuelEconomyConfig.makeQueryParameter: 'Ford',
            VehicleSpecsConfig.modelQueryParameter: 'F150 Pickup 2WD',
          },
        ),
      ).called(1);
    });

    test('la marca con espacios va como parámetro de consulta', () async {
      stubGet(<String, dynamic>{});
      await datasource.fetchOptions(2020, 'Alfa Romeo', 'Giulia');
      final captured =
          verify(
                () => dio.get<Object?>(
                  any(),
                  queryParameters: captureAny(named: 'queryParameters'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured[FuelEconomyConfig.makeQueryParameter], 'Alfa Romeo');
    });

    test('fetchOptionIds sigue devolviendo solo los ids', () async {
      stubGet({
        'menuItem': [
          {'text': 'a', 'value': '1'},
          {'text': 'b', 'value': '2'},
        ],
      });
      expect(await datasource.fetchOptionIds(2020, 'Toyota', 'Camry'), [1, 2]);
    });

    test('fetchVehicle pide /{id} y mapea los campos nuevos', () async {
      stubGet(corolla41213Json);
      final record = await datasource.fetchVehicle(41213);
      expect(record?.transmission, 'Automatic (AV-S10)');
      expect(record?.annualFuelCostUsd, 1750);
      verify(() => dio.get<Object?>('/41213', queryParameters: null)).called(1);
    });

    test('los errores de Dio en opciones se traducen a AppFailure', () async {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      await expectLater(
        datasource.fetchOptions(2020, 'Toyota', 'Camry'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('fetchOptions entra a la cola', () async {
      await queue.close();
      await expectLater(
        datasource.fetchOptions(2020, 'Toyota', 'Camry'),
        throwsA(isA<StateError>()),
      );
      verifyNever(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      );
    });
  });

  group('VehicleSpecsRepositoryImpl: opciones y detalle', () {
    late _MockDio dio;
    late VehicleSpecsRepositoryImpl repository;

    void stubGet(Object? Function(String path) answer) {
      when(
        () => dio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((invocation) async {
        final path = invocation.positionalArguments.first as String;
        return _response(answer(path));
      });
    }

    setUp(() {
      dio = _MockDio();
      final queue = ConcurrencyLimitedQueue(maxConcurrent: 2);
      repository = VehicleSpecsRepositoryImpl(
        datasource: FuelEconomyVehicleSpecsDatasource(dio: dio, queue: queue),
        queue: queue,
      );
    });

    test('getOptions devuelve las opciones en el orden de la API', () async {
      stubGet(
        (_) => {
          'menuItem': [
            {'text': 'Auto (AV-S10), 4 cyl, 2.0 L', 'value': '41213'},
            {'text': 'Man 6-spd, 4 cyl, 2.0 L', 'value': '41215'},
          ],
        },
      );
      final options = await repository.getOptions(2020, 'Toyota', 'Corolla');
      expect(options.map((option) => option.id), [41213, 41215]);
    });

    test('getDetail con registro nulo devuelve nulo', () async {
      stubGet((_) => null);
      expect(
        await repository.getDetail(
          1,
          year: 2020,
          brand: 'Toyota',
          model: 'Corolla',
        ),
        isNull,
      );
    });

    test(
      'getDetail con campos construye la ficha con la opción pedida',
      () async {
        stubGet((_) => corolla41213Json);
        final detail = await repository.getDetail(
          41213,
          year: 2020,
          brand: 'Toyota',
          model: 'Corolla',
        );
        expect(detail?.id, 41213);
        expect(detail?.make, 'Toyota');
        expect(detail?.powertrain, Powertrain.combustion);
        expect(
          detail?.combinedKmPerLiter,
          closeTo(
            34.2793 * UnitsConfig.milesPerGallonToKilometersPerLiter,
            1e-9,
          ),
        );
        expect(detail?.drive, 'Front-Wheel Drive');
      },
    );

    test('getDetail de un eléctrico no trae km/l', () async {
      stubGet((_) => tesla42274Json);
      final detail = await repository.getDetail(
        42274,
        year: 2020,
        brand: 'Tesla',
        model: 'Model 3 Long Range',
      );
      expect(detail?.powertrain, Powertrain.electric);
      expect(detail?.combinedKmPerLiter, isNull);
      expect(detail?.annualFuelCostUsd, 600);
    });
  });
}
