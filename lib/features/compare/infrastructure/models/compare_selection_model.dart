import 'package:isar_community/isar.dart';

part 'compare_selection_model.g.dart';

/// Selección del comparador de un mercado guardada en Isar.
@collection
class CompareSelectionModel {
  CompareSelectionModel({
    required this.key,
    required this.payload,
    required this.savedAtMillis,
    this.id = Isar.autoIncrement,
  });

  final Id id;

  /// Clave única versionada por mercado: escribirla reemplaza la fila.
  @Index(unique: true, replace: true)
  final String key;

  /// JSON con la lista ordenada de vehículos.
  final String payload;
  final int savedAtMillis;
}
