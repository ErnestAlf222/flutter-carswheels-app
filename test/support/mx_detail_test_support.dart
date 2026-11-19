import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

import 'conuee_test_support.dart';

/// Filas reales de diésel de CONUEE 2025 (Ford Transit Custom y Mitsubishi L200).
const List<Map<String, dynamic>> conueeDieselRows = [
  {
    '_id': 264,
    'marca': 'Ford',
    'modelo': 'TRANSIT CUSTOM 2.0L',
    'rendimiento_km_l_ciudad': 12.16,
    'rendimiento_km_l_carretera': 14.86,
    'rendimiento_km_l_combinado': 13.24,
    'emisiones_co2_g_km_ciudad': 221.0,
    'emisiones_co2_g_km_carretera': 180.0,
    'emisiones_co2_g_km_combinado': 203.0,
    'tipo_combustible': 'Diesel',
    'numero_cilindros': '4I',
    'desplazamiento_cm3': 2000.0,
    'tipo_transmision': 'Manual',
    'relacion_compresion': '16.5:1',
    'potencia_maxima_hp_rpm': '134@3500',
    'torque_maximo_n_m_rpm': '373 @ 1450',
  },
  {
    '_id': 546,
    'marca': 'Mitsubishi',
    'modelo': 'L200 GLX 4X2 2.4L 4CIL Diesel',
    'rendimiento_km_l_ciudad': 12.71,
    'rendimiento_km_l_carretera': 17.34,
    'rendimiento_km_l_combinado': 14.45,
    'emisiones_co2_g_km_ciudad': 211.0,
    'emisiones_co2_g_km_carretera': 155.0,
    'emisiones_co2_g_km_combinado': 186.0,
    'tipo_combustible': 'Diesel',
    'numero_cilindros': 'I4',
    'desplazamiento_cm3': 2442.0,
    'tipo_transmision': '6Mt',
    'relacion_compresion': '(15.2±1.5):1',
    'potencia_maxima_hp_rpm': '181@3500',
    'torque_maximo_n_m_rpm': '430@2250-2500',
  },
];

/// Fila diésel real ya limpia; [index] 0 es el Transit y 1 es la L200.
MxVehicleEntity dieselVehicle(int index) =>
    const MxVehicleMapper().map(index, conueeDieselRows[index])!.vehicle;

/// Versión de México con la fila real [model]; la etiqueta por defecto es el modelo.
MxVersionEntity mxVersion(String model, {String? label}) =>
    MxVersionEntity(label: label ?? model, vehicle: conueeVehicle(model));

/// Ficha de México de una fila real de los fixtures.
VehicleDetailEntity mxDetail(String model, {int year = 2025}) =>
    const MxVehicleDetailBuilder().build(conueeVehicle(model), year);
