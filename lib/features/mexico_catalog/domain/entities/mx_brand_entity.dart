import 'package:equatable/equatable.dart';

/// Marca con la cantidad de filas que tiene en el año.
class MxBrandEntity extends Equatable {
  const MxBrandEntity({required this.name, required this.vehicleCount});

  final String name;
  final int vehicleCount;

  @override
  List<Object?> get props => [name, vehicleCount];
}
