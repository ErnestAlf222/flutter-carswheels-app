import 'package:equatable/equatable.dart';

/// Estrellas generales de un grupo: rango y cuántas versiones están calificadas.
class GroupSafetyEntity extends Equatable {
  const GroupSafetyEntity({
    required this.ratedCount,
    this.minOverall,
    this.maxOverall,
  });

  /// Versiones con estrella general; con 0, el rango es nulo.
  final int ratedCount;
  final int? minOverall;
  final int? maxOverall;

  @override
  List<Object?> get props => [ratedCount, minOverall, maxOverall];
}
