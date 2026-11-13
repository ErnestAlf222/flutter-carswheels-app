import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_detail_entity.dart';

/// Detalle guardado junto con el momento en que se guardó.
class CachedDetailEntity extends Equatable {
  const CachedDetailEntity({required this.detail, required this.savedAt});

  final VehicleDetailEntity detail;
  final DateTime savedAt;

  @override
  List<Object?> get props => [detail, savedAt];
}
