import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';

/// Resultado guardado de una búsqueda de foto.
class CachedPhotoEntity extends Equatable {
  const CachedPhotoEntity({required this.photo, required this.savedAt});

  /// Nulo significa que se buscó y no hay foto.
  final PhotoEntity? photo;
  final DateTime savedAt;

  bool get isMiss => photo == null;

  @override
  List<Object?> get props => [photo, savedAt];
}
