import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';

/// Datos para abrir el visor: las fotos y la que se muestra primero.
class PhotoViewerArgsEntity extends Equatable {
  const PhotoViewerArgsEntity(this.photos, {this.initialIndex = 0});

  final List<PhotoEntity> photos;
  final int initialIndex;

  @override
  List<Object?> get props => [photos, initialIndex];
}
