import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/domain/datasources/nhtsa_recalls_datasource.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/recall_entity.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/mappers/recall_mapper.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/models/nhtsa_results_model.dart';

/// Recalls de NHTSA y modelos de vPIC; cada petición pasa por la cola compartida.
class NhtsaApiRecallsDatasource implements NhtsaRecallsDatasource {
  const NhtsaApiRecallsDatasource({
    required this.apiDio,
    required this.vpicDio,
    required this.queue,
  });

  final Dio apiDio;
  final Dio vpicDio;
  final ConcurrencyLimitedQueue queue;

  @override
  Future<List<RecallEntity>> fetchRecalls(int year, String make, String model) {
    return queue.enqueue(() => _fetchRecalls(year, make, model));
  }

  @override
  Future<List<String>> fetchVpicModelNames(int year, String make) {
    return queue.enqueue(() => _fetchVpicModelNames(year, make));
  }

  Future<List<RecallEntity>> _fetchRecalls(
    int year,
    String make,
    String model,
  ) async {
    try {
      final response = await apiDio.get<Object?>(
        SafetyConfig.recallsPath,
        queryParameters: {
          SafetyConfig.recallsMakeParameter: make,
          SafetyConfig.recallsModelParameter: model,
          SafetyConfig.recallsYearParameter: year,
        },
      );
      return _toRecalls(response.data);
    } on DioException catch (exception) {
      if (_isNoRecalls(exception)) return const [];
      throw DioFailureMapper.map(exception);
    }
  }

  Future<List<String>> _fetchVpicModelNames(int year, String make) async {
    final path = SafetyConfig.vpicModelsPathTemplate
        .replaceAll(SafetyConfig.yearPlaceholder, '$year')
        .replaceAll(SafetyConfig.makePlaceholder, Uri.encodeComponent(make));
    try {
      final response = await vpicDio.get<Object?>(
        path,
        queryParameters: {
          SafetyConfig.vpicFormatParameter: SafetyConfig.vpicFormatValue,
        },
      );
      final results = NhtsaResultsModel.fromJson(
        response.data,
        SafetyConfig.ratingsResultsKey,
      ).results;
      return [
        for (final item in results)
          if (item[SafetyConfig.vpicModelNameKey] is String)
            item[SafetyConfig.vpicModelNameKey] as String,
      ];
    } on DioException catch (exception) {
      throw DioFailureMapper.map(exception);
    }
  }

  List<RecallEntity> _toRecalls(Object? data) {
    final results = NhtsaResultsModel.fromJson(
      data,
      SafetyConfig.recallsResultsKey,
    ).results;
    return [
      for (final item in results)
        if (RecallMapper.toEntity(item) != null) RecallMapper.toEntity(item)!,
    ];
  }

  // Sin recalls la API responde 400 con Count 0; es un resultado vacío válido.
  bool _isNoRecalls(DioException exception) {
    final response = exception.response;
    final data = response?.data;
    return response?.statusCode == SafetyConfig.noRecallsStatus &&
        data is Map<String, dynamic> &&
        data[SafetyConfig.recallsCountKey] == 0;
  }
}
