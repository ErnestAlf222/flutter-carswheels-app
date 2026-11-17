import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/nhtsa_fixtures.dart';

class _FakeRatingsDatasource implements NhtsaSafetyRatingsDatasource {
  _FakeRatingsDatasource({
    required this.models,
    this.idsByModel = const {},
    this.ratingsById = const {},
  });

  final List<String> models;
  final Map<String, List<int>> idsByModel;
  final Map<int, SafetyRatingEntity> ratingsById;

  @override
  Future<List<String>> fetchModelNames(int year, String make) async => models;

  @override
  Future<List<int>> fetchVehicleIds(
    int year,
    String make,
    String modelName,
  ) async => idsByModel[modelName] ?? const [];

  @override
  Future<SafetyRatingEntity?> fetchRating(int vehicleId) async =>
      ratingsById[vehicleId];
}

class _FakeRecallsDatasource implements NhtsaRecallsDatasource {
  _FakeRecallsDatasource({this.recalls = const [], this.vpicModels = const []});

  final List<RecallEntity> recalls;
  final List<String> vpicModels;
  int vpicCalls = 0;

  @override
  Future<List<RecallEntity>> fetchRecalls(
    int year,
    String make,
    String model,
  ) async => recalls;

  @override
  Future<List<String>> fetchVpicModelNames(int year, String make) async {
    vpicCalls++;
    return vpicModels;
  }
}

void main() {
  group('SafetyRatingsRepositoryImpl', () {
    test('BMW X5: junta las dos versiones y respeta "Not Rated"', () async {
      final repository = SafetyRatingsRepositoryImpl(
        datasource: _FakeRatingsDatasource(
          models: const ['X5', 'X5 HYBRID', 'X5 M'],
          idsByModel: const {
            'X5': [19227, 19226],
          },
          ratingsById: const {
            19227: SafetyRatingEntity(
              overall: 4,
              front: 4,
              side: 5,
              rollover: 4,
            ),
            19226: SafetyRatingEntity(front: 4, side: 5),
          },
        ),
      );
      final group = await repository.getGroupSafety(2024, 'BMW', 'X5');
      expect(
        group,
        const GroupSafetyEntity(ratedCount: 1, minOverall: 4, maxOverall: 4),
      );
    });

    test('Civic por alias: el rango abarca sedán y hatchback', () async {
      final repository = SafetyRatingsRepositoryImpl(
        datasource: _FakeRatingsDatasource(
          models: honda2024Models,
          idsByModel: const {
            'CIVIC SEDAN': [1],
            'CIVIC HATCHBACK': [2],
          },
          ratingsById: const {
            1: SafetyRatingEntity(overall: 5),
            2: SafetyRatingEntity(overall: 4),
          },
        ),
      );
      final group = await repository.getGroupSafety(2024, 'Honda', 'Civic');
      expect(group!.minOverall, 4);
      expect(group.maxOverall, 5);
      expect(group.ratedCount, 2);
    });

    test('sin emparejar devuelve nulo, no un grupo vacío', () async {
      final repository = SafetyRatingsRepositoryImpl(
        datasource: _FakeRatingsDatasource(models: chevrolet2024Models),
      );
      expect(
        await repository.getGroupSafety(2024, 'Chevrolet', 'Silverado'),
        isNull,
      );
    });

    test('emparejado pero sin calificar: cuenta 0 (no nulo)', () async {
      final repository = SafetyRatingsRepositoryImpl(
        datasource: _FakeRatingsDatasource(
          models: tesla2024Models,
          idsByModel: const {
            'MODEL 3': [19950, 19949],
          },
          ratingsById: const {
            19950: SafetyRatingEntity(),
            19949: SafetyRatingEntity(),
          },
        ),
      );
      final group = await repository.getGroupSafety(2024, 'Tesla', 'Model 3');
      expect(group, const GroupSafetyEntity(ratedCount: 0));
    });
  });

  group('RecallsRepositoryImpl', () {
    const recall = RecallEntity(campaignNumber: '24V128000');

    test('con recalls siempre los devuelve', () async {
      final repository = RecallsRepositoryImpl(
        _FakeRecallsDatasource(recalls: const [recall]),
      );
      final summary = await repository.getRecalls(2024, 'Toyota', 'Camry');
      expect(summary!.count, 1);
    });

    test(
      'cero sin emparejar y único en vPIC (Aston Martin DBX) es 0',
      () async {
        final summary = await RecallsRepositoryImpl(
          _FakeRecallsDatasource(vpicModels: vpicAstonMartin2027Models),
        ).getRecalls(2027, 'Aston Martin', 'DBX');
        expect(summary!.count, 0);
      },
    );

    test('cero sin emparejar y ambiguo en vPIC (Silverado) es nulo', () async {
      final summary = await RecallsRepositoryImpl(
        _FakeRecallsDatasource(vpicModels: vpicChevrolet2024Models),
      ).getRecalls(2024, 'Chevrolet', 'Silverado');
      expect(summary, isNull);
    });

    test('cero sin emparejar y ausente en vPIC es nulo, no 0', () async {
      final summary = await RecallsRepositoryImpl(
        _FakeRecallsDatasource(vpicModels: const ['C-Class']),
      ).getRecalls(2024, 'Mercedes-Benz', 'C300');
      expect(summary, isNull);
    });
  });
}
