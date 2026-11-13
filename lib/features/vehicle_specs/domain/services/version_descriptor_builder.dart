import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_detail_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/services/transmission_labeler.dart';

/// Arma el descriptor corto de una versión: transmisión, cilindros y litros.
class VersionDescriptorBuilder {
  const VersionDescriptorBuilder({required this.transmissionLabeler});

  final TransmissionLabeler transmissionLabeler;

  /// Cadena vacía si la versión no trae ninguna de las partes.
  String describe(VehicleDetailEntity detail) {
    final cylinders = detail.cylinders;
    final liters = detail.displacementLiters;
    final parts = [
      transmissionLabeler.labelFor(detail.transmission),
      if (cylinders != null) AppTexts.cylindersLabel(cylinders),
      if (liters != null) AppTexts.displacementLabel(liters),
    ].whereType<String>();
    return parts.join(AppTexts.descriptorSeparator);
  }
}
