import 'package:equatable/equatable.dart';

/// Referencia a la foto principal guardada: su URL, los créditos y, si ya se
/// descargó, el nombre del archivo local.
class FavoritePhotoEntity extends Equatable {
  const FavoritePhotoEntity({
    required this.thumbnailUrl,
    required this.authorName,
    required this.licenseName,
    required this.sourceUrl,
    required this.isReference,
    this.aspectRatio,
    this.localFileName,
  });

  final String thumbnailUrl;
  final String authorName;
  final String licenseName;
  final String sourceUrl;

  /// Verdadero si la foto no es del año del favorito.
  final bool isReference;
  final double? aspectRatio;

  /// Archivo en la carpeta de fotos de favoritos; nulo si solo hay la URL.
  final String? localFileName;

  /// Misma foto con el archivo local indicado (o sin él).
  FavoritePhotoEntity withLocalFileName(String? fileName) =>
      FavoritePhotoEntity(
        thumbnailUrl: thumbnailUrl,
        authorName: authorName,
        licenseName: licenseName,
        sourceUrl: sourceUrl,
        isReference: isReference,
        aspectRatio: aspectRatio,
        localFileName: fileName,
      );

  @override
  List<Object?> get props => [
    thumbnailUrl,
    authorName,
    licenseName,
    sourceUrl,
    isReference,
    aspectRatio,
    localFileName,
  ];
}
