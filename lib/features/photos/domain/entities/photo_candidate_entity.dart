import 'package:equatable/equatable.dart';

/// Foto candidata devuelta por una búsqueda, aún sin elegir.
class PhotoCandidateEntity extends Equatable {
  const PhotoCandidateEntity({
    required this.title,
    required this.thumbnailUrl,
    required this.authorName,
    required this.licenseName,
    required this.sourceUrl,
    required this.rank,
    this.aspectRatio,
  });

  final String title;
  final String thumbnailUrl;
  final String authorName;
  final String licenseName;
  final String sourceUrl;
  final int rank;

  /// Ancho entre alto de la miniatura; nulo si no se conoce.
  final double? aspectRatio;

  @override
  List<Object?> get props => [
    title,
    thumbnailUrl,
    authorName,
    licenseName,
    sourceUrl,
    rank,
    aspectRatio,
  ];
}
