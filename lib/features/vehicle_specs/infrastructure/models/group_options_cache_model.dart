import 'package:isar_community/isar.dart';

part 'group_options_cache_model.g.dart';

/// Versiones (ids y textos) de una variante, guardadas para abrir Detalle sin red.
@collection
class GroupOptionsCacheModel {
  GroupOptionsCacheModel({
    required this.key,
    required this.optionIds,
    required this.optionTexts,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única: escribir una clave existente reemplaza la entrada.
  @Index(unique: true, replace: true)
  final String key;

  /// Ids y textos de las opciones, en el orden de la API (listas paralelas).
  final List<int> optionIds;
  final List<String> optionTexts;
  final int savedAtMillis;
}
