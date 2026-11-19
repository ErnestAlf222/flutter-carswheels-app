import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/infrastructure/models/cached_commons_logo_model.dart';

/// Convierte entre la entrada de Isar y la entidad de caché del logo.
class CachedCommonsLogoMapper {
  const CachedCommonsLogoMapper._();

  static CachedCommonsLogoEntity toEntity(CachedCommonsLogoModel model) =>
      CachedCommonsLogoEntity(
        logo: model.found
            ? CommonsLogoEntity(
                url: model.url,
                licenseName: model.licenseName,
                authorName: model.authorName,
                sourceUrl: model.sourceUrl,
              )
            : null,
        savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
      );

  /// Una búsqueda vacía deja los textos vacíos.
  static CachedCommonsLogoModel toModel(
    String key,
    CachedCommonsLogoEntity entity,
  ) {
    final logo = entity.logo;
    return CachedCommonsLogoModel(
      key: key,
      found: logo != null,
      url: logo?.url ?? '',
      licenseName: logo?.licenseName ?? '',
      authorName: logo?.authorName ?? '',
      sourceUrl: logo?.sourceUrl ?? '',
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }
}
