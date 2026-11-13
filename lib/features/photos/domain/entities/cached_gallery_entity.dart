import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';

/// Resultado guardado de la búsqueda de la galería de un modelo.
class CachedGalleryEntity extends Equatable {
  const CachedGalleryEntity({required this.photos, required this.savedAt});

  /// Vacía significa que se buscó y no hay fotos.
  final List<PhotoEntity> photos;
  final DateTime savedAt;

  bool get isMiss => photos.isEmpty;

  @override
  List<Object?> get props => [photos, savedAt];
}
