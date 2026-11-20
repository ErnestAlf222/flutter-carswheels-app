import 'package:equatable/equatable.dart';

/// Referencia a la foto principal guardada: su URL y los créditos.
class FavoritePhotoEntity extends Equatable {
  const FavoritePhotoEntity({
    required this.thumbnailUrl,
    required this.authorName,
    required this.licenseName,
    required this.sourceUrl,
    required this.isReference,
    this.aspectRatio,
  });

  final String thumbnailUrl;
  final String authorName;
  final String licenseName;
  final String sourceUrl;

  /// Verdadero si la foto no es del año del favorito.
  final bool isReference;
  final double? aspectRatio;

  @override
  List<Object?> get props => [
    thumbnailUrl,
    authorName,
    licenseName,
    sourceUrl,
    isReference,
    aspectRatio,
  ];
}
