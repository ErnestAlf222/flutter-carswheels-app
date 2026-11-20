import 'dart:convert';

import 'package:cars_wheels_app/core/config/favorites_config.dart';
import 'package:cars_wheels_app/features/favorites/domain/domain.dart';

/// Convierte un favorito a JSON y de vuelta, y arma la clave de Isar.
class FavoritePayloadMapper {
  const FavoritePayloadMapper._();

  /// Clave versionada: prefijo, versión y la identidad del favorito.
  static String keyFor(FavoriteIdentity identity) => [
    FavoritesConfig.storageKeyPrefix,
    FavoritesConfig.storageKeyVersion,
    identity.marketCode,
    identity.year,
    identity.brand,
    identity.groupKey,
  ].join(FavoritesConfig.storageKeySeparator);

  /// Clave de Isar de una clave de identidad (la que usa el dominio).
  static String storageKeyOf(String identityKey) => [
    FavoritesConfig.storageKeyPrefix,
    FavoritesConfig.storageKeyVersion,
    identityKey,
  ].join(FavoritesConfig.storageKeySeparator);

  static String toPayload(FavoriteEntity favorite) {
    final snapshot = favorite.snapshot;
    final photo = snapshot.photo;
    return jsonEncode({
      FavoritesConfig.payloadMarketKey: favorite.marketCode,
      FavoritesConfig.payloadYearKey: favorite.year,
      FavoritesConfig.payloadBrandKey: favorite.brand,
      FavoritesConfig.payloadGroupKey: favorite.identity.groupKey,
      FavoritesConfig.payloadModelKey: favorite.modelName,
      FavoritesConfig.payloadSavedAtKey:
          favorite.savedAt.millisecondsSinceEpoch,
      FavoritesConfig.payloadLabelKey: snapshot.label,
      FavoritesConfig.payloadEngineKindsKey: snapshot.engineKinds,
      FavoritesConfig.payloadMinKmKey: snapshot.minKmPerLiter,
      FavoritesConfig.payloadMaxKmKey: snapshot.maxKmPerLiter,
      FavoritesConfig.payloadVariantsKey: snapshot.variantNames,
      FavoritesConfig.payloadPhotoKey: photo == null
          ? null
          : {
              FavoritesConfig.payloadPhotoUrlKey: photo.thumbnailUrl,
              FavoritesConfig.payloadPhotoAuthorKey: photo.authorName,
              FavoritesConfig.payloadPhotoLicenseKey: photo.licenseName,
              FavoritesConfig.payloadPhotoSourceKey: photo.sourceUrl,
              FavoritesConfig.payloadPhotoReferenceKey: photo.isReference,
              FavoritesConfig.payloadPhotoAspectKey: photo.aspectRatio,
              FavoritesConfig.payloadPhotoLocalKey: photo.localFileName,
            },
    });
  }

  /// Lanza si el JSON no tiene la forma esperada; quien lee decide qué hacer.
  static FavoriteEntity fromPayload(String payload) {
    final json = jsonDecode(payload) as Map<String, dynamic>;
    final photoJson =
        json[FavoritesConfig.payloadPhotoKey] as Map<String, dynamic>?;
    return FavoriteEntity(
      identity: FavoriteIdentity(
        marketCode: json[FavoritesConfig.payloadMarketKey] as String,
        year: json[FavoritesConfig.payloadYearKey] as int,
        brand: json[FavoritesConfig.payloadBrandKey] as String,
        groupKey: json[FavoritesConfig.payloadGroupKey] as String,
        modelName: json[FavoritesConfig.payloadModelKey] as String,
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(
        json[FavoritesConfig.payloadSavedAtKey] as int,
      ),
      snapshot: FavoriteSnapshotEntity(
        label: json[FavoritesConfig.payloadLabelKey] as String?,
        engineKinds: [
          for (final kind
              in json[FavoritesConfig.payloadEngineKindsKey] as List<dynamic>)
            kind as String,
        ],
        minKmPerLiter: (json[FavoritesConfig.payloadMinKmKey] as num?)
            ?.toDouble(),
        maxKmPerLiter: (json[FavoritesConfig.payloadMaxKmKey] as num?)
            ?.toDouble(),
        variantNames: [
          for (final name
              in json[FavoritesConfig.payloadVariantsKey] as List<dynamic>)
            name as String,
        ],
        photo: photoJson == null
            ? null
            : FavoritePhotoEntity(
                thumbnailUrl:
                    photoJson[FavoritesConfig.payloadPhotoUrlKey] as String,
                authorName:
                    photoJson[FavoritesConfig.payloadPhotoAuthorKey] as String,
                licenseName:
                    photoJson[FavoritesConfig.payloadPhotoLicenseKey] as String,
                sourceUrl:
                    photoJson[FavoritesConfig.payloadPhotoSourceKey] as String,
                isReference:
                    photoJson[FavoritesConfig.payloadPhotoReferenceKey] as bool,
                aspectRatio:
                    (photoJson[FavoritesConfig.payloadPhotoAspectKey] as num?)
                        ?.toDouble(),
                // Ausente en lo guardado antes de las fotos locales: queda nulo.
                localFileName:
                    photoJson[FavoritesConfig.payloadPhotoLocalKey] as String?,
              ),
      ),
    );
  }
}
