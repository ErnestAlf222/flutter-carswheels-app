import 'package:isar_community/isar.dart';

part 'recalls_cache_model.g.dart';

/// Entrada de la caché de recalls de un grupo guardada en Isar.
@collection
class RecallsCacheModel {
  RecallsCacheModel({
    required this.key,
    required this.payload,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  /// JSON con la lista de recalls.
  final String payload;
  final int savedAtMillis;
}
