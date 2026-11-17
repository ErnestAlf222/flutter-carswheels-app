import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/cached_group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/infrastructure/models/safety_ratings_cache_model.dart';

/// Convierte entre la entrada de Isar y las estrellas guardadas de un grupo.
class CachedGroupSafetyMapper {
  const CachedGroupSafetyMapper._();

  static CachedGroupSafetyEntity toEntity(SafetyRatingsCacheModel model) {
    final json = jsonDecode(model.payload) as Map<String, dynamic>;
    return CachedGroupSafetyEntity(
      safety: GroupSafetyEntity(
        ratedCount: json[SafetyConfig.payloadRatedCountKey] as int,
        minOverall: json[SafetyConfig.payloadMinOverallKey] as int?,
        maxOverall: json[SafetyConfig.payloadMaxOverallKey] as int?,
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(model.savedAtMillis),
    );
  }

  static SafetyRatingsCacheModel toModel(
    String key,
    CachedGroupSafetyEntity entity,
  ) {
    final safety = entity.safety;
    return SafetyRatingsCacheModel(
      key: key,
      payload: jsonEncode({
        SafetyConfig.payloadRatedCountKey: safety.ratedCount,
        SafetyConfig.payloadMinOverallKey: safety.minOverall,
        SafetyConfig.payloadMaxOverallKey: safety.maxOverall,
      }),
      savedAtMillis: entity.savedAt.millisecondsSinceEpoch,
    );
  }
}
