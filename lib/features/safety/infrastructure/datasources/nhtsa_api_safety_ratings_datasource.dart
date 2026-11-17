import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/domain/datasources/nhtsa_safety_ratings_datasource.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/safety_rating_entity.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/mappers/safety_rating_mapper.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/models/nhtsa_results_model.dart';

/// Calificaciones sobre la API de NHTSA; cada petición pasa por la cola.
class NhtsaApiSafetyRatingsDatasource implements NhtsaSafetyRatingsDatasource {
  const NhtsaApiSafetyRatingsDatasource({
    required this.dio,
    required this.queue,
  });

  final Dio dio;
  final ConcurrencyLimitedQueue queue;

  @override
  Future<List<String>> fetchModelNames(int year, String make) {
    final path = SafetyConfig.ratingsModelsPathTemplate
        .replaceAll(SafetyConfig.yearPlaceholder, '$year')
        .replaceAll(SafetyConfig.makePlaceholder, Uri.encodeComponent(make));
    return queue.enqueue(() async {
      final results = await _results(path);
      return [
        for (final item in results)
          if (item[SafetyConfig.ratingsModelKey] is String)
            item[SafetyConfig.ratingsModelKey] as String,
      ];
    });
  }

  @override
  Future<List<int>> fetchVehicleIds(int year, String make, String modelName) {
    final path = SafetyConfig.ratingsVariantsPathTemplate
        .replaceAll(SafetyConfig.yearPlaceholder, '$year')
        .replaceAll(SafetyConfig.makePlaceholder, Uri.encodeComponent(make))
        .replaceAll(
          SafetyConfig.modelPlaceholder,
          Uri.encodeComponent(modelName),
        );
    return queue.enqueue(() async {
      final results = await _results(path);
      return [
        for (final item in results)
          if (item[SafetyConfig.ratingsVehicleIdKey] is int &&
              item[SafetyConfig.ratingsVehicleIdKey] !=
                  SafetyConfig.unratedVehicleId)
            item[SafetyConfig.ratingsVehicleIdKey] as int,
      ];
    });
  }

  @override
  Future<SafetyRatingEntity?> fetchRating(int vehicleId) {
    final path = SafetyConfig.ratingsVehiclePathTemplate.replaceAll(
      SafetyConfig.idPlaceholder,
      '$vehicleId',
    );
    return queue.enqueue(() async {
      final results = await _results(path);
      return results.isEmpty
          ? null
          : SafetyRatingMapper.toEntity(results.first);
    });
  }

  // Una petición; traduce los errores de Dio a AppFailure.
  Future<List<Map<String, dynamic>>> _results(String path) async {
    try {
      final response = await dio.get<Object?>(path);
      return NhtsaResultsModel.fromJson(
        response.data,
        SafetyConfig.ratingsResultsKey,
      ).results;
    } on DioException catch (exception) {
      throw DioFailureMapper.map(exception);
    }
  }
}
