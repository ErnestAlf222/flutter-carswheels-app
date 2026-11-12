import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/catalog/domain/entities/model_entity.dart';

/// Grupo de variantes de FuelEconomy que comparten un mismo modelo.
class ModelGroupEntity extends Equatable {
  const ModelGroupEntity({required this.name, required this.variants});

  /// Nombre del grupo, con las mayúsculas del nombre original.
  final String name;

  /// Modelos originales del grupo, en el orden de la lista original.
  final List<ModelEntity> variants;

  @override
  List<Object?> get props => [name, variants];
}
