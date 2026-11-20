import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Fila de [CompareConfig.maxSlots] columnas del mismo ancho que los espacios.
///
/// Los espacios y esta fila reparten el ancho igual, así cada valor queda
/// alineado debajo de su vehículo.
class CompareGridRowWidget extends StatelessWidget {
  const CompareGridRowWidget({
    super.key,
    required this.cellBuilder,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// Contenido de la columna [index], de 0 a maxSlots - 1.
  final Widget Function(int index) cellBuilder;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (int index = 0; index < CompareConfig.maxSlots; index++) ...[
          if (index > 0) const SizedBox(width: CompareConfig.slotGap),
          Expanded(child: cellBuilder(index)),
        ],
      ],
    );
  }
}
