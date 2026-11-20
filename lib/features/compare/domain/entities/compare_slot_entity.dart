import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/config/compare_config.dart';

/// Un vehículo elegido para comparar: grupo de modelo, año y versión opcional.
class CompareSlotEntity extends Equatable {
  const CompareSlotEntity({
    required this.marketCode,
    required this.year,
    required this.brand,
    required this.groupKey,
    required this.modelName,
    this.versionKey,
  });

  /// Código del mercado donde se eligió; las selecciones se guardan por mercado.
  final String marketCode;
  final int year;
  final String brand;

  /// Clave estable del grupo de modelo dentro de la marca.
  final String groupKey;

  /// Nombre del grupo tal como se muestra y se pide a fotos y resúmenes.
  final String modelName;

  /// Versión elegida; nula significa la predeterminada del grupo.
  final String? versionKey;

  /// Copia con otra versión; nula vuelve a la predeterminada.
  CompareSlotEntity withVersion(String? versionKey) => CompareSlotEntity(
    marketCode: marketCode,
    year: year,
    brand: brand,
    groupKey: groupKey,
    modelName: modelName,
    versionKey: versionKey,
  );

  /// Identidad para detectar duplicados: mercado, año, marca, grupo y versión.
  String get identity => [
    marketCode,
    year,
    brand,
    groupKey,
    versionKey ?? '',
  ].join(CompareConfig.identitySeparator);

  @override
  List<Object?> get props => [
    marketCode,
    year,
    brand,
    groupKey,
    modelName,
    versionKey,
  ];
}
