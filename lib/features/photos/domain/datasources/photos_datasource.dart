import 'package:cars_wheels_app/features/photos/domain/entities/photo_candidate_entity.dart';

/// Fuente de datos de fotos.
abstract class PhotosDatasource {
  Future<List<PhotoCandidateEntity>> searchCandidates(String searchTerm);
}
