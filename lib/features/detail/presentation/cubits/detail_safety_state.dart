import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';

/// Resultado de cargar una parte de la seguridad: cargando, con datos, sin datos o error.
sealed class SafetyLoad<T> extends Equatable {
  const SafetyLoad();

  @override
  List<Object?> get props => [];
}

/// Todavía no llega la respuesta.
class SafetyLoading<T> extends SafetyLoad<T> {
  const SafetyLoading();
}

/// Hay un valor que mostrar.
class SafetyData<T> extends SafetyLoad<T> {
  const SafetyData(this.value);

  final T value;

  @override
  List<Object?> get props => [value];
}

/// Sin emparejar o sin calificar: se muestra "—".
class SafetyEmpty<T> extends SafetyLoad<T> {
  const SafetyEmpty();
}

/// La carga falló: se muestra "—".
class SafetyFailed<T> extends SafetyLoad<T> {
  const SafetyFailed(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}

/// Estrellas y recalls de Detalle; cada parte avanza por su cuenta.
class DetailSafetyState extends Equatable {
  const DetailSafetyState({
    this.ratings = const SafetyLoading<GroupSafetyEntity>(),
    this.recalls = const SafetyLoading<RecallSummaryEntity>(),
  });

  final SafetyLoad<GroupSafetyEntity> ratings;
  final SafetyLoad<RecallSummaryEntity> recalls;

  DetailSafetyState copyWith({
    SafetyLoad<GroupSafetyEntity>? ratings,
    SafetyLoad<RecallSummaryEntity>? recalls,
  }) => DetailSafetyState(
    ratings: ratings ?? this.ratings,
    recalls: recalls ?? this.recalls,
  );

  @override
  List<Object?> get props => [ratings, recalls];
}
