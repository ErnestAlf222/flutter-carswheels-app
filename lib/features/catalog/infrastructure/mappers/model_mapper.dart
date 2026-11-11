import 'package:cars_wheels_app/features/catalog/domain/entities/model_entity.dart';

/// Convierte textos de items del menú en modelos.
class ModelMapper {
  const ModelMapper._();

  /// Descarta los textos vacíos y conserva el resto sin cambios.
  static List<ModelEntity> toModels(List<String> itemTexts) => itemTexts
      .where((text) => text.trim().isNotEmpty)
      .map((text) => ModelEntity(name: text))
      .toList();
}
