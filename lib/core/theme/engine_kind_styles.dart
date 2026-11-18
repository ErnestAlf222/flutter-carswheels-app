import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/theme/app_colors.dart';

/// Ícono y color de un tipo de motorización.
class EngineKindStyle {
  const EngineKindStyle({required this.icon, required this.color});

  final IconData icon;
  final Color color;
}

/// Único mapa tipo de motorización → ícono y color; la clave es el nombre del enum.
class EngineKindStyles {
  const EngineKindStyles._();

  static const Map<String, EngineKindStyle> byName = {
    'electric': EngineKindStyle(
      icon: Symbols.bolt,
      color: AppColors.engineElectric,
    ),
    'pluginHybrid': EngineKindStyle(
      icon: Symbols.electrical_services,
      color: AppColors.enginePluginHybrid,
    ),
    'hybrid': EngineKindStyle(
      icon: Symbols.energy_savings_leaf,
      color: AppColors.engineHybrid,
    ),
    'hydrogen': EngineKindStyle(
      icon: Symbols.water_drop,
      color: AppColors.engineHydrogen,
    ),
    'diesel': EngineKindStyle(
      icon: Symbols.local_gas_station,
      color: AppColors.engineDiesel,
    ),
    'gasoline': EngineKindStyle(
      icon: Symbols.local_gas_station,
      color: AppColors.engineFuel,
    ),
    'flexFuel': EngineKindStyle(
      icon: Symbols.local_gas_station,
      color: AppColors.engineFuel,
    ),
  };

  /// Estilo de un tipo; uno neutro si el nombre no está en el mapa.
  static EngineKindStyle forName(String name) =>
      byName[name] ??
      const EngineKindStyle(
        icon: Symbols.local_gas_station,
        color: AppColors.engineFuel,
      );
}
