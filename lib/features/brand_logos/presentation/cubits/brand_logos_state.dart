import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Estado de la carga de logos.
sealed class BrandLogosState extends Equatable {
  const BrandLogosState();

  @override
  List<Object?> get props => [];
}

class BrandLogosInitial extends BrandLogosState {
  const BrandLogosInitial();
}

class BrandLogosLoading extends BrandLogosState {
  const BrandLogosLoading();
}

class BrandLogosLoaded extends BrandLogosState {
  const BrandLogosLoaded(
    this.logoUrls, {
    this.fallbackUrls = const {},
    this.generation = 0,
  });

  /// Nombre de marca normalizado → URL del logo.
  final Map<String, String> logoUrls;

  /// Logos de respaldo de Commons, solo para marcas sin logo en el conjunto.
  final Map<String, String> fallbackUrls;

  /// Sube al volver la conexión para que los logos que fallaron se pidan de nuevo.
  final int generation;

  @override
  List<Object?> get props => [logoUrls, fallbackUrls, generation];
}

class BrandLogosError extends BrandLogosState {
  const BrandLogosError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
