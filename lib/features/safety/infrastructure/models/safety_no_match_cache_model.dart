import 'package:isar_community/isar.dart';

part 'safety_no_match_cache_model.g.dart';

/// Marca de "no emparejado con NHTSA" guardada en Isar.
@collection
class SafetyNoMatchCacheModel {
  SafetyNoMatchCacheModel({
    required this.key,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;
  final int savedAtMillis;
}
