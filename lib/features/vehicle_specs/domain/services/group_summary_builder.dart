import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_summary_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/powertrain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_record_entity.dart';

/// Construye el resumen de un grupo a partir de los registros de sus variantes.
class GroupSummaryBuilder {
  const GroupSummaryBuilder();

  static const String _emptyMessage = 'No hay registros para resumir';

  GroupSummaryEntity build(List<VehicleRecordEntity> records) {
    if (records.isEmpty) throw ArgumentError(_emptyMessage);
    final kmPerLiter = <double>[];
    final powertrains = <Powertrain>{};
    for (final record in records) {
      final powertrain = _classify(record.atvType);
      final mpg = record.combinedMpg;
      powertrains.add(powertrain);
      if (powertrain == Powertrain.combustion && mpg != null) {
        kmPerLiter.add(mpg * UnitsConfig.milesPerGallonToKilometersPerLiter);
      }
    }
    return GroupSummaryEntity(
      vehicleClass: _mostFrequentClass(records),
      minKmPerLiter: kmPerLiter.isEmpty
          ? null
          : kmPerLiter.reduce((a, b) => a < b ? a : b),
      maxKmPerLiter: kmPerLiter.isEmpty
          ? null
          : kmPerLiter.reduce((a, b) => a > b ? a : b),
      hasElectric: powertrains.contains(Powertrain.electric),
      hasPluginHybrid: powertrains.contains(Powertrain.pluginHybrid),
      variantCount: records.length,
    );
  }

  // La clase más repetida; en empate gana la que apareció primero.
  String? _mostFrequentClass(List<VehicleRecordEntity> records) {
    final counts = <String, int>{};
    for (final record in records) {
      final name = record.vehicleClass;
      if (name != null) counts[name] = (counts[name] ?? 0) + 1;
    }
    final best = counts.entries.fold<MapEntry<String, int>?>(
      null,
      (current, entry) =>
          current == null || entry.value > current.value ? entry : current,
    );
    return best?.key;
  }

  // Sin distinguir mayúsculas; un valor no listado es other.
  Powertrain _classify(String atvType) {
    final name =
        VehicleSpecsConfig.powertrainByAtvType[atvType.trim().toLowerCase()] ??
        VehicleSpecsConfig.otherPowertrainName;
    return Powertrain.values.firstWhere(
      (powertrain) => powertrain.name == name,
      orElse: () => Powertrain.other,
    );
  }
}
