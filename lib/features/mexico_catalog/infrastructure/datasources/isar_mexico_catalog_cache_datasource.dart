import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/mexico_catalog/domain/datasources/mexico_catalog_cache_datasource.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/cached_mx_year_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/cached_mx_years_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/infrastructure/mappers/mx_cache_payload_mapper.dart';
import 'package:cars_wheels_app/features/mexico_catalog/infrastructure/models/mexico_catalog_cache_model.dart';

/// Caché del catálogo de México guardada en Isar.
class IsarMexicoCatalogCacheDatasource implements MexicoCatalogCacheDatasource {
  const IsarMexicoCatalogCacheDatasource(this.isar);

  final Isar isar;

  @override
  Future<CachedMxYearsEntity?> readYears(String key) async {
    final model = await isar.mexicoCatalogCacheModels.getByKey(key);
    if (model == null) return null;
    try {
      return CachedMxYearsEntity(
        sources: MxCachePayloadMapper.sourcesFromPayload(model.payload),
        savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
      );
    } on Object {
      // Un payload ilegible cuenta como entrada ausente.
      return null;
    }
  }

  @override
  Future<void> writeYears(String key, CachedMxYearsEntity entry) {
    return _write(
      key,
      MxCachePayloadMapper.sourcesToPayload(entry.sources),
      entry.savedAt,
    );
  }

  @override
  Future<CachedMxYearEntity?> readYear(String key) async {
    final model = await isar.mexicoCatalogCacheModels.getByKey(key);
    if (model == null) return null;
    try {
      return CachedMxYearEntity(
        catalog: MxCachePayloadMapper.catalogFromPayload(model.payload),
        savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<void> writeYear(String key, CachedMxYearEntity entry) {
    return _write(
      key,
      MxCachePayloadMapper.catalogToPayload(entry.catalog),
      entry.savedAt,
    );
  }

  Future<void> _write(String key, String payload, DateTime savedAt) {
    final model = MexicoCatalogCacheModel(
      key: key,
      payload: payload,
      savedAtMillis: savedAt.millisecondsSinceEpoch,
    );
    return isar.writeTxn(() => isar.mexicoCatalogCacheModels.putByKey(model));
  }
}
