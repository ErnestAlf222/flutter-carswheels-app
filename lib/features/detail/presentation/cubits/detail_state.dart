import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';

/// Estado de la pantalla Detalle.
sealed class DetailState extends Equatable {
  const DetailState();

  @override
  List<Object?> get props => [];
}

/// Todavía no se pidió nada.
class DetailInitial extends DetailState {
  const DetailInitial();
}

/// Se están cargando las versiones.
class DetailLoading extends DetailState {
  const DetailLoading();
}

/// Hay versiones y una está seleccionada.
class DetailLoaded extends DetailState {
  const DetailLoaded({required this.details, required this.selectedIndex});

  final GroupDetailsEntity details;
  final int selectedIndex;

  @override
  List<Object?> get props => [details, selectedIndex];
}

/// El grupo no tiene versiones con datos.
class DetailEmpty extends DetailState {
  const DetailEmpty();
}

/// La carga falló.
class DetailError extends DetailState {
  const DetailError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
