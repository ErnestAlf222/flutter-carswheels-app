import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Convierte la foto guardada de un favorito en la foto que muestran las pantallas.
///
/// Si su archivo local existe lo lleva en [PhotoEntity.localPath]: las pantallas
/// lo usan antes que la red.
PhotoEntity favoritePhotoEntityOf(
  BuildContext context,
  FavoritePhotoEntity photo,
) {
  final fileName = photo.localFileName;
  return PhotoEntity(
    thumbnailUrl: photo.thumbnailUrl,
    authorName: photo.authorName,
    licenseName: photo.licenseName,
    sourceUrl: photo.sourceUrl,
    isReference: photo.isReference,
    aspectRatio: photo.aspectRatio,
    localPath: fileName == null ? null : _store(context)?.pathOf(fileName),
  );
}

// Sin carpeta de fotos (por ejemplo en una prueba) solo se usa la red.
FavoritePhotoStore? _store(BuildContext context) {
  try {
    return context.read<FavoritePhotoStore>();
  } on ProviderNotFoundException {
    return null;
  }
}
