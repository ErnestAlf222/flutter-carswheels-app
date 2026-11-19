import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/datasources/mexico_catalog_datasource.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_catalog_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_source_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/infrastructure/mappers/mx_year_catalog_mapper.dart';
import 'package:cars_wheels_app/features/mexico_catalog/infrastructure/models/conuee_response_models.dart';

/// Catálogo de CONUEE por CKAN; cada petición pasa por la cola compartida.
class ConueeApiDatasource implements MexicoCatalogDatasource {
  const ConueeApiDatasource({
    required this.dio,
    required this.queue,
    this.mapper = const MxYearCatalogMapper(),
  });

  final Dio dio;
  final ConcurrencyLimitedQueue queue;
  final MxYearCatalogMapper mapper;

  static final RegExp _yearPattern = RegExp(ConueeConfig.resourceYearPattern);

  @override
  Future<List<MxYearSourceEntity>> fetchYearSources() async {
    final data = await queue.enqueue(
      () => _get(ConueeConfig.packageShowPath, {
        ConueeConfig.packageIdParameter: ApiConfig.conueeDatasetId,
      }),
    );
    final package = ConueePackageModel.fromJson(data);
    final sources = <MxYearSourceEntity>[];
    for (final resource in package.resources) {
      final year = int.tryParse(
        _yearPattern.firstMatch(resource.name)?.group(1) ?? '',
      );
      if (year == null || !resource.datastoreActive) continue;
      sources.add(MxYearSourceEntity(year: year, resourceId: resource.id));
    }
    return sources..sort((a, b) => b.year.compareTo(a.year));
  }

  @override
  Future<MxYearCatalogEntity> fetchYear(MxYearSourceEntity source) async {
    final rows = <Map<String, dynamic>>[];
    int total = 0;
    do {
      final page = ConueeRecordsModel.fromJson(
        await queue.enqueue(
          () => _get(ConueeConfig.datastoreSearchPath, {
            ConueeConfig.resourceIdParameter: source.resourceId,
            ConueeConfig.limitParameter: ConueeConfig.maxRecordsPerRequest,
            ConueeConfig.offsetParameter: rows.length,
          }),
        ),
      );
      total = page.total;
      if (page.records.isEmpty) break;
      rows.addAll(page.records);
    } while (rows.length < total);
    return mapper.toEntity(source.year, rows);
  }

  Future<Object?> _get(String path, Map<String, Object> query) async {
    try {
      final response = await dio.get<Object?>(path, queryParameters: query);
      return response.data;
    } on DioException catch (exception) {
      throw DioFailureMapper.map(exception);
    }
  }
}
