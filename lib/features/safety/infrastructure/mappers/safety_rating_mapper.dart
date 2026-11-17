import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/safety_rating_entity.dart';

/// Convierte un resultado de calificaciones de NHTSA en su entidad.
class SafetyRatingMapper {
  const SafetyRatingMapper._();

  static SafetyRatingEntity toEntity(Map<String, dynamic> json) {
    return SafetyRatingEntity(
      overall: parseStars(json[SafetyConfig.overallRatingKey]),
      front: parseStars(json[SafetyConfig.frontRatingKey]),
      side: parseStars(json[SafetyConfig.sideRatingKey]),
      rollover: parseStars(json[SafetyConfig.rolloverRatingKey]),
    );
  }

  /// "Not Rated", vacío o fuera de 1 a 5 es dato ausente.
  static int? parseStars(Object? value) {
    final stars = int.tryParse('${value ?? ''}'.trim());
    if (stars == null) return null;
    final inRange =
        stars >= SafetyConfig.ratingMin && stars <= SafetyConfig.ratingMax;
    return inRange ? stars : null;
  }
}
