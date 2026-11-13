import 'package:equatable/equatable.dart';

/// Una versión disponible de un modelo: id del vehículo y su texto.
class VehicleOptionEntity extends Equatable {
  const VehicleOptionEntity({required this.id, required this.text});

  final int id;

  /// Texto de la opción tal como llega de la API.
  final String text;

  @override
  List<Object?> get props => [id, text];
}
