import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Mensaje breve que el comparador muestra por un momento.
enum CompareNotice {
  /// El vehículo ya estaba en la lista.
  alreadyAdded,

  /// La lista ya tiene el máximo de vehículos.
  full,
}

/// Estado del comparador del mercado activo.
sealed class CompareState extends Equatable {
  const CompareState();

  @override
  List<Object?> get props => [];
}

/// Se está leyendo la selección guardada del mercado.
class CompareLoading extends CompareState {
  const CompareLoading();
}

/// Selección lista, con un mensaje breve opcional.
class CompareLoaded extends CompareState {
  const CompareLoaded({
    required this.selection,
    this.notice,
    this.noticeId = 0,
  });

  final CompareSelectionEntity selection;
  final CompareNotice? notice;

  /// Cambia con cada mensaje nuevo, aunque sea el mismo texto.
  final int noticeId;

  CompareLoaded copyWith({
    CompareSelectionEntity? selection,
    CompareNotice? notice,
    int? noticeId,
    bool clearNotice = false,
  }) => CompareLoaded(
    selection: selection ?? this.selection,
    notice: clearNotice ? null : notice ?? this.notice,
    noticeId: noticeId ?? this.noticeId,
  );

  @override
  List<Object?> get props => [selection, notice, noticeId];
}
