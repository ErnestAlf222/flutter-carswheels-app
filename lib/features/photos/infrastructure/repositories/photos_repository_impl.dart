import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/datasources/photos_datasource.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_candidate_entity.dart';
import 'package:cars_wheels_app/features/photos/domain/repositories/photos_repository.dart';

/// Repositorio de fotos sobre un PhotosDatasource.
class PhotosRepositoryImpl implements PhotosRepository {
  const PhotosRepositoryImpl(this._datasource, this._queue);

  final PhotosDatasource _datasource;

  /// Cola de Commons, para cancelar lo pendiente.
  final RateLimitedQueue _queue;

  @override
  Future<List<PhotoCandidateEntity>> searchCandidates(String searchTerm) =>
      _datasource.searchCandidates(searchTerm);

  @override
  void cancelPendingSearches() => _queue.cancelPending();
}
