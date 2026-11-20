import 'package:equatable/equatable.dart';

/// Valor de un vehículo en una fila de la tabla.
class CompareTableCellEntity extends Equatable {
  const CompareTableCellEntity({required this.text, this.isBest = false});

  /// Texto ya listo; es el de "sin dato" cuando el vehículo no lo tiene.
  final String text;

  /// Es el mejor valor de la fila.
  final bool isBest;

  @override
  List<Object?> get props => [text, isBest];
}
