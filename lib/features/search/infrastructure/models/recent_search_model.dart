import 'package:isar_community/isar.dart';

part 'recent_search_model.g.dart';

/// Búsqueda reciente guardada en Isar.
@collection
class RecentSearchModel {
  RecentSearchModel({
    required this.key,
    required this.text,
    required this.searchedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la fila.
  @Index(unique: true, replace: true)
  final String key;
  final String text;
  final int searchedAtMillis;
}
