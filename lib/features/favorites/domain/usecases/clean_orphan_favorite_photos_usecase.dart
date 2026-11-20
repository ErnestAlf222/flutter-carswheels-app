import 'package:cars_wheels_app/features/favorites/domain/datasources/favorite_photo_store.dart';
import 'package:cars_wheels_app/features/favorites/domain/datasources/favorites_datasource.dart';
import 'package:cars_wheels_app/features/favorites/domain/services/favorite_orphan_planner.dart';

/// Borra las fotos de la carpeta que ningún favorito guardado usa.
class CleanOrphanFavoritePhotosUseCase {
  const CleanOrphanFavoritePhotosUseCase({
    required this.datasource,
    required this.store,
    required this.clock,
    required this.grace,
    this.planner = const FavoriteOrphanPlanner(),
  });

  final FavoritesDatasource datasource;
  final FavoritePhotoStore store;
  final FavoriteOrphanPlanner planner;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  /// Los archivos más nuevos que esto no se tocan (pueden estar descargándose).
  final Duration grace;

  /// Devuelve cuántos archivos borró.
  Future<int> call() async {
    final favorites = await datasource.readAll();
    final referenced = {
      for (final favorite in favorites) ?favorite.snapshot.photo?.localFileName,
    };
    final orphans = planner.orphansOf(
      stored: await store.list(),
      referenced: referenced,
      now: clock(),
      grace: grace,
    );
    for (final name in orphans) {
      await store.delete(name);
    }
    return orphans.length;
  }
}
