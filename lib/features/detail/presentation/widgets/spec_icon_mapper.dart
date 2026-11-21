import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';

/// Único mapa de tipo de dato de la ficha → ícono y título de sección.
class SpecIconMapper {
  const SpecIconMapper._();

  static const Map<SpecKind, IconData> _icons = {
    SpecKind.fuel: Symbols.local_gas_station,
    SpecKind.powertrain: Symbols.energy_savings_leaf,
    SpecKind.cylinders: Symbols.engineering,
    SpecKind.displacement: Symbols.data_usage,
    SpecKind.aspiration: Symbols.air,
    SpecKind.transmission: Symbols.conversion_path,
    SpecKind.drive: Symbols.directions_car,
    SpecKind.power: Symbols.speed,
    SpecKind.torque: Symbols.rotate_right,
    SpecKind.compression: Symbols.compress,
    SpecKind.startStop: Symbols.play_pause,
    SpecKind.cityConsumption: Symbols.commute,
    SpecKind.highwayConsumption: Symbols.moving,
    SpecKind.combinedConsumption: Symbols.avg_pace,
    SpecKind.hybridGasConsumption: Symbols.local_gas_station,
    SpecKind.electricConsumption: Symbols.bolt,
    SpecKind.annualCost: Symbols.payments,
    SpecKind.electricRange: Symbols.route,
    SpecKind.totalRange: Symbols.route,
    SpecKind.chargeTime: Symbols.battery_charging_full,
    SpecKind.co2: Symbols.co2,
    SpecKind.cityCo2: Symbols.co2,
    SpecKind.highwayCo2: Symbols.co2,
    SpecKind.vehicleClass: Symbols.category,
    SpecKind.passengerVolume: Symbols.airline_seat_recline_normal,
    SpecKind.cargoVolume: Symbols.luggage,
  };

  static const Map<SpecSection, String> _sectionTitles = {
    SpecSection.engine: SpecSheetTexts.engineSection,
    SpecSection.consumption: SpecSheetTexts.consumptionSection,
    SpecSection.energy: SpecSheetTexts.energySection,
    SpecSection.body: SpecSheetTexts.bodySection,
  };

  /// Ícono de una fila; el combustible toma el de su tipo de motorización.
  static IconData iconFor(SpecEntryEntity entry) {
    final engineKind = entry.engineKindName;
    if (entry.kind == SpecKind.fuel && engineKind != null) {
      return EngineKindStyles.forName(engineKind).icon;
    }
    return _icons[entry.kind] ?? Symbols.list_alt;
  }

  static String titleFor(SpecSection section) =>
      _sectionTitles[section] ?? SpecSheetTexts.engineSection;
}
