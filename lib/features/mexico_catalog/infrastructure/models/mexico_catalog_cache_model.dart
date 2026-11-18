import 'package:isar_community/isar.dart';

part 'mexico_catalog_cache_model.g.dart';

/// Entrada de la caché del catálogo de México guardada en Isar.
@collection
class MexicoCatalogCacheModel {
  MexicoCatalogCacheModel({
    required this.key,
    required this.payload,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  /// JSON con la lista de años o con las filas de un año.
  final String payload;
  final int savedAtMillis;
}
