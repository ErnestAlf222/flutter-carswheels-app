import 'package:isar_community/isar.dart';

part 'safety_ratings_cache_model.g.dart';

/// Entrada de la caché de estrellas de un grupo guardada en Isar.
@collection
class SafetyRatingsCacheModel {
  SafetyRatingsCacheModel({
    required this.key,
    required this.payload,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  /// JSON con el rango y la cantidad de versiones calificadas.
  final String payload;
  final int savedAtMillis;
}
