import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';

/// Estado de la carga de modelos.
sealed class ModelsState extends Equatable {
  const ModelsState();

  @override
  List<Object?> get props => [];
}

class ModelsInitial extends ModelsState {
  const ModelsInitial();
}

class ModelsLoading extends ModelsState {
  const ModelsLoading();
}

class ModelsLoaded extends ModelsState {
  const ModelsLoaded({required this.models, required this.visibleCount});

  /// Lista completa de modelos.
  final List<ModelEntity> models;

  /// Cantidad de modelos visibles hasta ahora.
  final int visibleCount;

  @override
  List<Object?> get props => [models, visibleCount];
}

class ModelsError extends ModelsState {
  const ModelsError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
