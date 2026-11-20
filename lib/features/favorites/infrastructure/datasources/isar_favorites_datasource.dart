import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/core/config/favorites_config.dart';
import 'package:cars_wheels_app/features/favorites/domain/domain.dart';
import 'package:cars_wheels_app/features/favorites/infrastructure/mappers/favorite_payload_mapper.dart';
import 'package:cars_wheels_app/features/favorites/infrastructure/models/favorite_model.dart';

/// Favoritos guardados en Isar, una fila por modelo.
class IsarFavoritesDatasource implements FavoritesDatasource {
  const IsarFavoritesDatasource(this.isar);

  final Isar isar;

  // Un payload ilegible o de otra versión se ignora: cuenta como no guardado.
  FavoriteEntity? _decode(FavoriteModel? model) {
    if (model == null) return null;
    try {
      return FavoritePayloadMapper.fromPayload(model.payload);
    } on Object {
      return null;
    }
  }

  @override
  Future<List<FavoriteEntity>> readAll() async {
    final prefix = [
      FavoritesConfig.storageKeyPrefix,
      FavoritesConfig.storageKeyVersion,
      '',
    ].join(FavoritesConfig.storageKeySeparator);
    final models = await isar.favoriteModels
        .filter()
        .keyStartsWith(prefix)
        .findAll();
    return [for (final model in models) ?_decode(model)];
  }

  // Las claves del dominio son las de identidad; aquí se pasan a las de Isar.
  @override
  Future<FavoriteEntity?> read(String key) async => _decode(
    await isar.favoriteModels.getByKey(FavoritePayloadMapper.storageKeyOf(key)),
  );

  @override
  Future<void> put(FavoriteEntity favorite) {
    final model = FavoriteModel(
      key: FavoritePayloadMapper.keyFor(favorite.identity),
      payload: FavoritePayloadMapper.toPayload(favorite),
      savedAtMillis: favorite.savedAt.millisecondsSinceEpoch,
    );
    return isar.writeTxn(() => isar.favoriteModels.putByKey(model));
  }

  @override
  Future<void> remove(String key) => isar.writeTxn(
    () => isar.favoriteModels.deleteByKey(
      FavoritePayloadMapper.storageKeyOf(key),
    ),
  );

  @override
  Stream<List<FavoriteEntity>> watchAll() => isar.favoriteModels
      .watchLazy(fireImmediately: true)
      .asyncMap((_) => readAll());
}
