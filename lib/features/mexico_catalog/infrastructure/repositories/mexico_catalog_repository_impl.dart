import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/datasources/mexico_catalog_cache_datasource.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/datasources/mexico_catalog_datasource.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/cached_mx_year_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/cached_mx_years_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_catalog_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_year_source_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/repositories/mexico_catalog_repository.dart';

/// Catálogo de México con memoria, caché en disco y red, en ese orden.
class MexicoCatalogRepositoryImpl implements MexicoCatalogRepository {
  MexicoCatalogRepositoryImpl({
    required this.datasource,
    required this.cache,
    required this.clock,
  });

  final MexicoCatalogDatasource datasource;
  final MexicoCatalogCacheDatasource cache;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  final Map<int, CachedMxYearEntity> _memory = {};
  final Map<int, Future<MxYearCatalogEntity>> _inFlight = {};

  @override
  Future<List<int>> fetchYears() async {
    final sources = await _resolveSources();
    return [for (final source in sources) source.year];
  }

  @override
  Future<MxYearCatalogEntity> fetchYear(int year) {
    final memorized = _memory[year];
    if (memorized != null && _isFresh(memorized.savedAt)) {
      return Future.value(memorized.catalog);
    }
    return _inFlight[year] ??= _load(year).whenComplete(() {
      // Con llaves: devolver el Future quitado haría que se espere a sí mismo.
      _inFlight.remove(year);
    });
  }

  Future<MxYearCatalogEntity> _load(int year) async {
    final key = _key(ConueeConfig.yearKeyKind, '$year');
    final cached = await cache.readYear(key);
    if (cached != null && _isFresh(cached.savedAt)) {
      _memory[year] = cached;
      return cached.catalog;
    }
    try {
      final sources = await _resolveSources();
      final source = sources.where((entry) => entry.year == year).firstOrNull;
      if (source == null) {
        throw const ParsingFailure(ConueeConfig.yearNotOfferedMessage);
      }
      final entry = CachedMxYearEntity(
        catalog: await datasource.fetchYear(source),
        savedAt: clock(),
      );
      await cache.writeYear(key, entry);
      _memory[year] = entry;
      return entry.catalog;
    } on AppFailure {
      if (cached != null) return cached.catalog;
      rethrow;
    }
  }

  Future<List<MxYearSourceEntity>> _resolveSources() async {
    final key = _key(ConueeConfig.yearsKeyKind, ConueeConfig.yearsKeyKind);
    final cached = await cache.readYears(key);
    if (cached != null && _isFresh(cached.savedAt)) return cached.sources;
    try {
      final sources = await datasource.fetchYearSources();
      await cache.writeYears(
        key,
        CachedMxYearsEntity(sources: sources, savedAt: clock()),
      );
      return sources;
    } on AppFailure {
      if (cached != null) return cached.sources;
      rethrow;
    }
  }

  String _key(String kind, String id) => [
    ConueeConfig.cacheKeyVersion,
    kind,
    id,
  ].join(ConueeConfig.cacheKeySeparator);

  // Vigente mientras no cumpla los días de vigencia.
  bool _isFresh(DateTime savedAt) =>
      clock().difference(savedAt) <
      const Duration(days: ConueeConfig.cacheTimeToLiveDays);
}
