import 'package:equatable/equatable.dart';

/// Pedido de la foto de un modelo.
class PhotoRequest extends Equatable {
  const PhotoRequest({
    required this.brand,
    required this.model,
    required this.year,
  });

  final String brand;

  /// Nombre del modelo tal como lo entrega FuelEconomy.
  final String model;
  final int year;

  @override
  List<Object?> get props => [brand, model, year];
}
