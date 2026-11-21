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
    this.widthPixels,
    this.heightPixels,
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

  /// Tamaño real de la foto guardada; nulo si aún no se midió.
  final int? widthPixels;
  final int? heightPixels;

  /// Ancho entre alto: el real si se midió; si no, el que dio la fuente; si no, nulo.
  double? get proportion {
    final width = widthPixels;
    final height = heightPixels;
    if (width != null && height != null && width > 0 && height > 0) {
      return width / height;
    }
    return aspectRatio;
  }

  /// Verdadero si ya se conoce el tamaño real.
  bool get hasDimensions => (widthPixels ?? 0) > 0 && (heightPixels ?? 0) > 0;

  /// Misma foto con su tamaño real.
  FavoritePhotoEntity withDimensions(int width, int height) =>
      FavoritePhotoEntity(
        thumbnailUrl: thumbnailUrl,
        authorName: authorName,
        licenseName: licenseName,
        sourceUrl: sourceUrl,
        isReference: isReference,
        aspectRatio: aspectRatio,
        localFileName: localFileName,
        widthPixels: width,
        heightPixels: height,
      );

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
        widthPixels: widthPixels,
        heightPixels: heightPixels,
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
    widthPixels,
    heightPixels,
  ];
}
