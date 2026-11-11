import 'package:equatable/equatable.dart';

/// Modelo de vehículo.
class ModelEntity extends Equatable {
  const ModelEntity({required this.name});

  final String name;

  @override
  List<Object?> get props => [name];
}
