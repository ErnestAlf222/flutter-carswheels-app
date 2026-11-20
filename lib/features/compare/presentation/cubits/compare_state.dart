import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Mensaje breve que el comparador muestra por un momento.
enum CompareNotice {
  /// El vehículo ya estaba en la lista.
  alreadyAdded,

  /// La lista ya tiene el máximo de vehículos.
  full,

  /// Se agregó un vehículo; lleva su nombre.
  added,

  /// Un vehículo reemplazó a otro; lleva los dos nombres.
  replaced,

  /// Se empezó una comparación nueva con un vehículo; lleva su nombre.
  startedNew,
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
    this.noticeSubject,
    this.noticeOther,
    this.noticeId = 0,
  });

  final CompareSelectionEntity selection;
  final CompareNotice? notice;

  /// Nombre del vehículo del mensaje, si lo lleva.
  final String? noticeSubject;

  /// Nombre del segundo vehículo del mensaje (el que salió), si lo lleva.
  final String? noticeOther;

  /// Cambia con cada mensaje nuevo, aunque sea el mismo texto.
  final int noticeId;

  CompareLoaded copyWith({
    CompareSelectionEntity? selection,
    CompareNotice? notice,
    String? noticeSubject,
    String? noticeOther,
    int? noticeId,
    bool clearNotice = false,
  }) => CompareLoaded(
    selection: selection ?? this.selection,
    notice: clearNotice ? null : notice ?? this.notice,
    noticeSubject: clearNotice ? null : noticeSubject ?? this.noticeSubject,
    noticeOther: clearNotice ? null : noticeOther ?? this.noticeOther,
    noticeId: noticeId ?? this.noticeId,
  );

  @override
  List<Object?> get props => [
    selection,
    notice,
    noticeSubject,
    noticeOther,
    noticeId,
  ];
}
