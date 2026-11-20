import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Carga de los datos de un vehículo de la tabla.
sealed class CompareColumnState extends Equatable {
  const CompareColumnState();

  @override
  List<Object?> get props => [];
}

/// Los datos de este vehículo todavía no llegan.
class CompareColumnLoading extends CompareColumnState {
  const CompareColumnLoading();
}

/// Datos listos; lo que falte en ellos es nulo.
class CompareColumnLoaded extends CompareColumnState {
  const CompareColumnLoaded(this.detail);

  final CompareVehicleDetailEntity detail;

  @override
  List<Object?> get props => [detail];
}

/// No se pudieron cargar; se puede reintentar.
class CompareColumnFailed extends CompareColumnState {
  const CompareColumnFailed();
}

/// Columnas de la tabla por vehículo, indexadas por su identidad.
class CompareTableState extends Equatable {
  const CompareTableState([this.columns = const {}]);

  final Map<String, CompareColumnState> columns;

  /// Datos de cada vehículo en el orden dado; nulo si aún carga o falló.
  List<CompareVehicleDetailEntity?> detailsOf(List<CompareSlotEntity> slots) =>
      [
        for (final slot in slots)
          switch (of(slot)) {
            CompareColumnLoaded(:final detail) => detail,
            _ => null,
          },
      ];

  /// Estado de la columna de un vehículo; cargando si aún no se pidió.
  CompareColumnState of(CompareSlotEntity slot) =>
      columns[slot.identity] ?? const CompareColumnLoading();

  @override
  List<Object?> get props => [columns];
}
