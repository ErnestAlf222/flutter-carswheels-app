import 'package:equatable/equatable.dart';

/// Una versión elegible de un modelo: su clave guardada y cómo se muestra.
class CompareVersionOptionEntity extends Equatable {
  const CompareVersionOptionEntity({
    required this.key,
    required this.label,
    this.caption,
  });

  /// Clave que se guarda en el espacio (variantName en EE. UU., rawModel en México).
  final String key;

  /// Texto principal legible.
  final String label;

  /// Texto secundario opcional, por ejemplo el nombre original de la variante.
  final String? caption;

  @override
  List<Object?> get props => [key, label, caption];
}
