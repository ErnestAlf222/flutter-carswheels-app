import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/repositories/photos_repository.dart';
import 'package:cars_wheels_app/features/photos/domain/services/photo_candidate_selector.dart';
import 'package:cars_wheels_app/features/photos/domain/services/photo_search_term_builder.dart';

/// Busca las fotos de un modelo: con año y, si faltan, también sin año.
class GetModelGalleryUseCase {
  const GetModelGalleryUseCase({
    required this.repository,
    required this.selector,
  });

  final PhotosRepository repository;
  final PhotoCandidateSelector selector;

  /// Hace como máximo dos búsquedas; devuelve hasta galleryMaxPhotos fotos.
  Future<List<PhotoEntity>> call({
    required String brand,
    required String modelName,
    required int year,
  }) async {
    final terms = PhotoSearchTermBuilder(selector: selector);
    final withYear = await repository.searchCandidates(
      terms.withYear(brand: brand, modelName: modelName, year: year),
    );
    final first = selector.selectMany(
      withYear,
      brand,
      modelName,
      year,
      PhotosConfig.galleryMaxPhotos,
    );
    if (first.length >= PhotosConfig.galleryMinPhotosBeforeSecondSearch) {
      return first;
    }
    final withoutYear = await repository.searchCandidates(
      terms.base(brand: brand, modelName: modelName),
    );
    // Lo hallado sin año nunca cuenta como del año pedido: va de referencia.
    final second = selector
        .selectMany(
          withoutYear,
          brand,
          modelName,
          year,
          PhotosConfig.galleryMaxPhotos,
        )
        .map(_asReference);
    final seenSources = <String>{};
    return [...first, ...second]
        .where((photo) => seenSources.add(photo.sourceUrl))
        .take(PhotosConfig.galleryMaxPhotos)
        .toList();
  }

  PhotoEntity _asReference(PhotoEntity photo) => PhotoEntity(
    thumbnailUrl: photo.thumbnailUrl,
    authorName: photo.authorName,
    licenseName: photo.licenseName,
    sourceUrl: photo.sourceUrl,
    isReference: true,
  );
}
