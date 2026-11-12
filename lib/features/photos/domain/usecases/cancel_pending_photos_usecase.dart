import 'package:cars_wheels_app/features/photos/domain/repositories/photos_repository.dart';

/// Cancela las búsquedas de fotos que aún no empezaron.
class CancelPendingPhotosUseCase {
  const CancelPendingPhotosUseCase(this.repository);

  final PhotosRepository repository;

  void call() => repository.cancelPendingSearches();
}
