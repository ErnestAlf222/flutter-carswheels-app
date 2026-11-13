import 'package:cars_wheels_app/features/photos/domain/entities/photo_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/repositories/photos_repository.dart';
import 'package:cars_wheels_app/features/photos/domain/services/photo_candidate_selector.dart';
import 'package:cars_wheels_app/features/photos/domain/services/photo_search_term_builder.dart';

/// Busca la foto de un modelo: primero con año y luego sin año.
class GetModelPhotoUseCase {
  const GetModelPhotoUseCase({
    required this.repository,
    required this.selector,
  });

  final PhotosRepository repository;
  final PhotoCandidateSelector selector;

  /// Hace como máximo dos búsquedas; devuelve null si no hay foto.
  Future<PhotoEntity?> call({
    required String brand,
    required String modelName,
    required int year,
  }) async {
    final terms = PhotoSearchTermBuilder(selector: selector);
    final withYear = await repository.searchCandidates(
      terms.withYear(brand: brand, modelName: modelName, year: year),
    );
    final exact = selector.select(withYear, brand, modelName, year);
    if (exact != null) return exact;
    final withoutYear = await repository.searchCandidates(
      terms.base(brand: brand, modelName: modelName),
    );
    final reference = selector.select(withoutYear, brand, modelName, year);
    if (reference == null) return null;
    return PhotoEntity(
      thumbnailUrl: reference.thumbnailUrl,
      authorName: reference.authorName,
      licenseName: reference.licenseName,
      sourceUrl: reference.sourceUrl,
      isReference: true,
    );
  }
}
