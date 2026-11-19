import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/infrastructure/mappers/cached_commons_logo_mapper.dart';
import 'package:cars_wheels_app/features/brand_logos/infrastructure/models/cached_commons_logo_model.dart';

/// Caché de logos de respaldo guardada en Isar.
class IsarCommonsLogoCacheDatasource implements CommonsLogoCacheDatasource {
  const IsarCommonsLogoCacheDatasource(this.isar);

  final Isar isar;

  @override
  Future<CachedCommonsLogoEntity?> read(String key) async {
    final model = await isar.cachedCommonsLogoModels.getByKey(key);
    return model == null ? null : CachedCommonsLogoMapper.toEntity(model);
  }

  @override
  Future<void> write(String key, CachedCommonsLogoEntity entry) {
    final model = CachedCommonsLogoMapper.toModel(key, entry);
    return isar.writeTxn(() => isar.cachedCommonsLogoModels.putByKey(model));
  }
}
