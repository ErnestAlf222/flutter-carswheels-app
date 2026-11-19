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
  const BrandLogosLoaded(this.logoUrls, {this.fallbackUrls = const {}});

  /// Nombre de marca normalizado → URL del logo.
  final Map<String, String> logoUrls;

  /// Logos de respaldo de Commons, solo para marcas sin logo en el conjunto.
  final Map<String, String> fallbackUrls;

  @override
  List<Object?> get props => [logoUrls, fallbackUrls];
}

class BrandLogosError extends BrandLogosState {
  const BrandLogosError(this.failure);

  final AppFailure failure;

  @override
  List<Object?> get props => [failure];
}
