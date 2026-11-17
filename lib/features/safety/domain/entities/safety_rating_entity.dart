import 'package:equatable/equatable.dart';

/// Estrellas NHTSA de una versión; nulo si no está calificada.
class SafetyRatingEntity extends Equatable {
  const SafetyRatingEntity({
    this.overall,
    this.front,
    this.side,
    this.rollover,
  });

  final int? overall;
  final int? front;
  final int? side;
  final int? rollover;

  @override
  List<Object?> get props => [overall, front, side, rollover];
}
