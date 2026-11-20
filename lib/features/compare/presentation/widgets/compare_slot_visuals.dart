import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Arma la foto de un vehículo elegido; lo implementa la capa app.
typedef CompareSlotPhotoBuilder = Widget Function(
  BuildContext context,
  CompareSlotEntity slot,
);

/// Arma el logo de la marca de un vehículo elegido; lo implementa la capa app.
typedef CompareSlotLogoBuilder = Widget Function(
  BuildContext context,
  CompareSlotEntity slot,
  double size,
);

/// Constructores de foto y logo que la capa app entrega a la pantalla.
class CompareSlotVisuals {
  const CompareSlotVisuals({
    required this.photoBuilder,
    required this.logoBuilder,
  });

  final CompareSlotPhotoBuilder photoBuilder;
  final CompareSlotLogoBuilder logoBuilder;
}
