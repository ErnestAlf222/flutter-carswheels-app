import 'package:equatable/equatable.dart';

/// Una fila de la ficha técnica: nombre del dato y su valor ya legible.
class SpecEntryEntity extends Equatable {
  const SpecEntryEntity({required this.label, required this.value});

  final String label;
  final String value;

  @override
  List<Object?> get props => [label, value];
}
