import 'package:isar_community/isar.dart';

part 'cached_commons_logo_model.g.dart';

/// Entrada de la caché de logos de respaldo guardada en Isar.
@collection
class CachedCommonsLogoModel {
  CachedCommonsLogoModel({
    required this.key,
    required this.found,
    required this.url,
    required this.licenseName,
    required this.authorName,
    required this.sourceUrl,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  /// Falso significa que se buscó y no hay logo aceptable.
  final bool found;
  final String url;
  final String licenseName;
  final String authorName;
  final String sourceUrl;
  final int savedAtMillis;
}
