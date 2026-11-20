import 'package:isar_community/isar.dart';

part 'favorite_model.g.dart';

/// Un favorito guardado en Isar; la clave versionada lo identifica.
@collection
class FavoriteModel {
  FavoriteModel({
    required this.key,
    required this.payload,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única versionada: escribirla reemplaza la fila.
  @Index(unique: true, replace: true)
  final String key;

  /// JSON con la identidad, la instantánea y la foto.
  final String payload;
  final int savedAtMillis;
}
