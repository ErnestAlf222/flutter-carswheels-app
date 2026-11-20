import 'package:cars_wheels_app/features/favorites/domain/entities/stored_photo_file.dart';
import 'package:cars_wheels_app/features/favorites/domain/services/favorite_photo_namer.dart';

/// Decide qué archivos de la carpeta de fotos ya no son de ningún favorito.
class FavoriteOrphanPlanner {
  const FavoriteOrphanPlanner({this.namer = const FavoritePhotoNamer()});

  final FavoritePhotoNamer namer;

  /// Nombres a borrar: los que ningún favorito usa y no son recientes.
  ///
  /// Un archivo reciente puede ser una descarga en curso, y lo que no tiene la
  /// forma de una foto de la app no se toca.
  List<String> orphansOf({
    required Iterable<StoredPhotoFile> stored,
    required Set<String> referenced,
    required DateTime now,
    required Duration grace,
  }) => [
    for (final file in stored)
      if (_isOwnFile(file.name) &&
          !referenced.contains(file.name) &&
          now.difference(file.modified) >= grace)
        file.name,
  ];

  bool _isOwnFile(String name) =>
      namer.isPhotoFile(name) || namer.isPartialFile(name);
}
