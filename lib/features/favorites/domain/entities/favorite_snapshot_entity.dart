import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_photo_entity.dart';

/// Lo necesario para mostrar la tarjeta de un favorito sin red.
///
/// Todo es opcional: lo que no se pudo resolver queda nulo o vacío, nunca inventado.
class FavoriteSnapshotEntity extends Equatable {
  const FavoriteSnapshotEntity({
    this.label,
    this.engineKinds = const [],
    this.minKmPerLiter,
    this.maxKmPerLiter,
    this.variantNames = const [],
    this.photo,
  });

  /// Sin datos: el favorito se guardó antes de resolver su resumen.
  static const FavoriteSnapshotEntity empty = FavoriteSnapshotEntity();

  /// Clase (EE. UU.) o combustible (México), ya traducido como se muestra hoy.
  final String? label;

  /// Tipos de motorización por nombre, en orden de prioridad.
  final List<String> engineKinds;

  /// Rango de consumo de combustión; nulo si el grupo no lo tiene.
  final double? minKmPerLiter;
  final double? maxKmPerLiter;

  /// Variantes del grupo; Detalle de EE. UU. las necesita para abrirse.
  final List<String> variantNames;
  final FavoritePhotoEntity? photo;

  /// Verdadero si no trae ningún dato.
  bool get isEmpty =>
      label == null &&
      engineKinds.isEmpty &&
      minKmPerLiter == null &&
      maxKmPerLiter == null &&
      variantNames.isEmpty &&
      photo == null;

  /// Copia que conserva [fallback] como variantes si esta no trae ninguna.
  FavoriteSnapshotEntity withVariantsIfMissing(List<String> fallback) =>
      variantNames.isNotEmpty || fallback.isEmpty
      ? this
      : FavoriteSnapshotEntity(
          label: label,
          engineKinds: engineKinds,
          minKmPerLiter: minKmPerLiter,
          maxKmPerLiter: maxKmPerLiter,
          variantNames: fallback,
          photo: photo,
        );

  @override
  List<Object?> get props => [
    label,
    engineKinds,
    minKmPerLiter,
    maxKmPerLiter,
    variantNames,
    photo,
  ];
}
