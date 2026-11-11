import 'package:equatable/equatable.dart';

/// Marca de vehículos.
class BrandEntity extends Equatable {
  const BrandEntity({required this.name});

  final String name;

  @override
  List<Object?> get props => [name];
}
