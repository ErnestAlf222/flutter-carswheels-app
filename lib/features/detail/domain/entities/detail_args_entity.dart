import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/photos/photos.dart';

/// Lo que necesita Detalle para abrir un grupo de modelos.
class DetailArgsEntity extends Equatable {
  const DetailArgsEntity({
    required this.brand,
    required this.groupName,
    required this.year,
    required this.variantNames,
    required this.photo,
    required this.heroTag,
  });

  final String brand;
  final String groupName;
  final int year;
  final List<String> variantNames;

  /// Foto que ya se mostraba en la lista, para pintarla al instante.
  final PhotoEntity? photo;
  final String heroTag;

  @override
  List<Object?> get props => [
    brand,
    groupName,
    year,
    variantNames,
    photo,
    heroTag,
  ];
}
