import 'package:cars_wheels_app/features/brand_logos/domain/entities/commons_logo_candidate_entity.dart';

/// Búsqueda de logos de marcas en Wikimedia Commons.
abstract class CommonsLogoDatasource {
  Future<List<CommonsLogoCandidateEntity>> searchLogos(String brandName);
}
