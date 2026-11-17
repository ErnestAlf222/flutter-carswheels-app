import 'package:cars_wheels_app/features/safety/domain/entities/cached_group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/cached_recalls_entity.dart';

/// Cachés de seguridad: estrellas, recalls y "no emparejado".
abstract class SafetyCacheDatasource {
  Future<CachedGroupSafetyEntity?> readRatings(String key);

  /// Reemplaza la entrada si la clave ya existe.
  Future<void> writeRatings(String key, CachedGroupSafetyEntity entry);

  Future<CachedRecallsEntity?> readRecalls(String key);

  Future<void> writeRecalls(String key, CachedRecallsEntity entry);

  /// Momento en que se guardó la marca de "no emparejado", si existe.
  Future<DateTime?> readNoMatch(String key);

  Future<void> writeNoMatch(String key, DateTime savedAt);
}
