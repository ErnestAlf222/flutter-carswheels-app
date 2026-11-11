import 'package:cars_wheels_app/features/catalog/domain/entities/model_entity.dart';

/// Convierte textos de items del menú en modelos.
class ModelMapper {
  const ModelMapper._();

  /// Recorta los espacios de los extremos y descarta los textos vacíos.
  static List<ModelEntity> toModels(List<String> itemTexts) => itemTexts
      .map((text) => text.trim())
      .where((text) => text.isNotEmpty)
      .map((text) => ModelEntity(name: text))
      .toList();
}
