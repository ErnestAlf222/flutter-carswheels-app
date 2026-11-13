import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_detail_entity.dart';

/// Elige la versión de consumo mediano para mostrar al abrir un grupo.
class DefaultVersionSelector {
  const DefaultVersionSelector();

  /// Índice en la lista original; lanza ArgumentError si la lista está vacía.
  int selectIndex(List<VehicleDetailEntity> details) {
    if (details.isEmpty) {
      throw ArgumentError.value(details, 'details', 'no puede estar vacía');
    }
    final candidates = [
      for (final (index, detail) in details.indexed)
        if (detail.powertrain == Powertrain.combustion &&
            detail.combinedKmPerLiter != null)
          index,
    ];
    if (candidates.isEmpty) return 0;
    // En empate de consumo gana la posición original.
    candidates.sort((a, b) {
      final byConsumption = details[a].combinedKmPerLiter!.compareTo(
        details[b].combinedKmPerLiter!,
      );
      return byConsumption != 0 ? byConsumption : a.compareTo(b);
    });
    return candidates[(candidates.length - 1) ~/ 2];
  }
}
