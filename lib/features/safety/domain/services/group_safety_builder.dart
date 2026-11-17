import 'package:cars_wheels_app/features/safety/domain/entities/group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/safety_rating_entity.dart';

/// Resume las calificaciones de las versiones de un grupo.
class GroupSafetyBuilder {
  const GroupSafetyBuilder();

  GroupSafetyEntity build(List<SafetyRatingEntity> ratings) {
    final overall = [
      for (final rating in ratings)
        if (rating.overall != null) rating.overall!,
    ];
    if (overall.isEmpty) return const GroupSafetyEntity(ratedCount: 0);
    return GroupSafetyEntity(
      ratedCount: overall.length,
      minOverall: overall.reduce((a, b) => a < b ? a : b),
      maxOverall: overall.reduce((a, b) => a > b ? a : b),
    );
  }
}
