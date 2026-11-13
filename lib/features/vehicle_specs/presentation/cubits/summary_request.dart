import 'package:equatable/equatable.dart';

/// Pedido del resumen de un grupo de modelos.
class SummaryRequest extends Equatable {
  const SummaryRequest({
    required this.brand,
    required this.groupName,
    required this.year,
    required this.variantNames,
  });

  final String brand;
  final String groupName;
  final int year;

  /// Nombres de las variantes del grupo, tal como los entrega FuelEconomy.
  final List<String> variantNames;

  @override
  List<Object?> get props => [brand, groupName, year, variantNames];
}
