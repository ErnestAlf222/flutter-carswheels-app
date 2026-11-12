import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingRepository implements PhotosRepository {
  int cancelCalls = 0;

  @override
  void cancelPendingSearches() => cancelCalls++;

  @override
  Future<List<PhotoCandidateEntity>> searchCandidates(
    String searchTerm,
  ) async => const [];
}

void main() {
  test('pide al repositorio cancelar las búsquedas pendientes', () {
    final repository = _CountingRepository();
    CancelPendingPhotosUseCase(repository)();
    expect(repository.cancelCalls, 1);
  });
}
