import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_version_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Resumen de un grupo de México a partir de sus versiones; no hay clase de vehículo.
class MxGroupSummaryBuilder {
  const MxGroupSummaryBuilder();

  // Solo combustión e híbridos tienen un km/l comparable.
  static const Set<EngineKind> _kmPerLiterKinds = {
    EngineKind.gasoline,
    EngineKind.diesel,
    EngineKind.hybrid,
    EngineKind.flexFuel,
  };

  /// Nulo si el grupo no tiene versiones.
  GroupSummaryEntity? build(List<MxVersionEntity> versions) {
    if (versions.isEmpty) return null;
    final kinds = <EngineKind>{};
    final kmPerLiter = <double>[];
    for (final version in versions) {
      final vehicle = version.vehicle;
      final kind = vehicle.engineKind;
      if (kind != null) kinds.add(kind);
      final combined = vehicle.combinedKmPerLiter;
      if (kind != null && _kmPerLiterKinds.contains(kind) && combined != null) {
        kmPerLiter.add(combined);
      }
    }
    return GroupSummaryEntity(
      vehicleClass: null,
      minKmPerLiter: kmPerLiter.isEmpty
          ? null
          : kmPerLiter.reduce((a, b) => a < b ? a : b),
      maxKmPerLiter: kmPerLiter.isEmpty
          ? null
          : kmPerLiter.reduce((a, b) => a > b ? a : b),
      hasElectric: kinds.contains(EngineKind.electric),
      hasPluginHybrid: kinds.contains(EngineKind.pluginHybrid),
      hasFuelCell: kinds.contains(EngineKind.hydrogen),
      variantCount: versions.length,
      // El orden del enum es la prioridad de la insignia.
      engineKinds: [
        for (final kind in EngineKind.values)
          if (kinds.contains(kind)) kind,
      ],
      fuelLabel: _fuelLabel(versions),
    );
  }

  // Combustibles distintos del grupo, del más frecuente al menos; nulo si no hay dato.
  static String? _fuelLabel(List<MxVersionEntity> versions) {
    final counts = <String, int>{};
    final labels = <String, String>{};
    for (final version in versions) {
      final raw = version.vehicle.fuelType;
      if (raw == null) continue;
      final key = TextNormalizer.normalize(raw);
      labels.putIfAbsent(key, () => AppTexts.mexicoFuelLabels[key] ?? raw);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    // Dart no garantiza sort estable: el empate se rompe por primera aparición.
    final order = counts.keys.toList();
    final ordered = [...order]
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0
            ? byCount
            : order.indexOf(a).compareTo(order.indexOf(b));
      });
    return ordered.map((key) => labels[key]!).join(AppTexts.fuelListSeparator);
  }
}
