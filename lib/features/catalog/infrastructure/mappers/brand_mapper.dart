import 'package:cars_wheels_app/features/catalog/domain/entities/brand_entity.dart';

/// Convierte textos de items del menú en entidades y años.
class BrandMapper {
  const BrandMapper._();

  static BrandEntity toBrand(String itemText) => BrandEntity(name: itemText);

  /// Ignora los valores no numéricos.
  static List<int> toYears(List<String> itemTexts) =>
      itemTexts.map(int.tryParse).whereType<int>().toList();
}
