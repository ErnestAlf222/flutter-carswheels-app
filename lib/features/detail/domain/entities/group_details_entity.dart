import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/detail/domain/entities/group_version_entity.dart';

/// Todas las versiones de un grupo y la que se muestra al abrir.
class GroupDetailsEntity extends Equatable {
  const GroupDetailsEntity({
    required this.versions,
    required this.defaultIndex,
  });

  final List<GroupVersionEntity> versions;
  final int defaultIndex;

  @override
  List<Object?> get props => [versions, defaultIndex];
}
