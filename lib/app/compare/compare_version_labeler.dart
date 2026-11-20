import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Nombre legible de una versión, con la misma regla de la hoja de Detalle.
class CompareVersionLabeler {
  const CompareVersionLabeler(this.descriptorBuilder);

  final VersionDescriptorBuilder descriptorBuilder;

  /// Con etiqueta propia (México) es esa; si no, el descriptor, y sin él la variante.
  String labelOf(GroupVersionEntity version) {
    final own = version.label;
    if (own != null) return own;
    final descriptor = descriptorBuilder.describe(version.detail);
    return descriptor.isEmpty ? version.variantName : descriptor;
  }

  /// Opción elegible: la clave guardada es siempre el nombre de la variante.
  CompareVersionOptionEntity optionOf(GroupVersionEntity version) {
    final label = labelOf(version);
    return CompareVersionOptionEntity(
      key: version.variantName,
      label: label,
      // El nombre original ayuda a distinguir descriptores repetidos.
      caption: label == version.variantName ? null : version.variantName,
    );
  }
}
