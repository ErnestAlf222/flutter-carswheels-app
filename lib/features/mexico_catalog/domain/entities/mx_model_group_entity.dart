import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_version_entity.dart';

/// Versiones del catálogo que comparten una misma familia de modelo.
class MxModelGroupEntity extends Equatable {
  const MxModelGroupEntity({required this.name, required this.versions});

  final String name;
  final List<MxVersionEntity> versions;

  @override
  List<Object?> get props => [name, versions];
}
