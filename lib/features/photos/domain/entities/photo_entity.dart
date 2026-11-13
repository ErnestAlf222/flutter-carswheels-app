import 'package:equatable/equatable.dart';

/// Foto elegida para un modelo.
class PhotoEntity extends Equatable {
  const PhotoEntity({
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

  /// Verdadero si la foto no es del año pedido.
  final bool isReference;

  /// Ancho entre alto de la miniatura; nulo si no se conoce.
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
