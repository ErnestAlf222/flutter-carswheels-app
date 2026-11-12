import 'package:cars_wheels_app/features/photos/domain/entities/photo_candidate_entity.dart';

/// Repositorio de fotos.
abstract class PhotosRepository {
  Future<List<PhotoCandidateEntity>> searchCandidates(String searchTerm);

  /// Cancela las búsquedas que aún no empezaron.
  void cancelPendingSearches();
}
