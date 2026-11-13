import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/photos/photos.dart';

/// Estado de la galería de fotos de Detalle.
class GalleryState extends Equatable {
  const GalleryState({
    this.photos = const [],
    this.currentIndex = 0,
    this.isLoading = false,
  });

  final List<PhotoEntity> photos;
  final int currentIndex;
  final bool isLoading;

  @override
  List<Object?> get props => [photos, currentIndex, isLoading];
}
