import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/safety/domain/entities/group_safety_entity.dart';

/// Estrellas de un grupo guardadas con el momento en que se guardaron.
class CachedGroupSafetyEntity extends Equatable {
  const CachedGroupSafetyEntity({required this.safety, required this.savedAt});

  final GroupSafetyEntity safety;
  final DateTime savedAt;

  @override
  List<Object?> get props => [safety, savedAt];
}
