import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/cubits/brand_logos_state.dart';

/// Carga las URLs de los logos y las resuelve por nombre de marca.
class BrandLogosCubit extends Cubit<BrandLogosState> {
  BrandLogosCubit(
    this._repository, {
    this._resolveCommonsLogo,
    List<String> brandsWithoutLogo = LogosConfig.brandsWithoutUsableLogo,
  }) : _brandsWithoutLogo = brandsWithoutLogo
           .map(TextNormalizer.normalize)
           .toSet(),
       super(const BrandLogosInitial());

  final BrandLogosRepository _repository;
  final ResolveCommonsLogoUseCase? _resolveCommonsLogo;
  final Set<String> _brandsWithoutLogo;
  // Marcas ya pedidas a Commons y marcas que esperan a que cargue el manifiesto.
  final Set<String> _requested = {};
  final Map<String, String> _pending = {};

  Future<void> loadLogos() async {
    if (state is BrandLogosLoading) return;
    emit(const BrandLogosLoading());
    try {
      emit(BrandLogosLoaded(await _repository.getLogoUrlsByBrand()));
      _pending.values.toList().forEach(ensureLogo);
      _pending.clear();
    } on AppFailure catch (failure) {
      emit(BrandLogosError(failure));
    } catch (error) {
      emit(BrandLogosError(UnknownFailure(error.toString())));
    }
  }

  /// URL del logo de la marca, o null si no hay logo, no es usable o aún no carga.
  String? urlFor(String brandName) {
    final current = state;
    if (current is! BrandLogosLoaded) return null;
    final key = _keyFor(brandName);
    if (!_brandsWithoutLogo.contains(key)) {
      final url = current.logoUrls[key];
      if (url != null) return url;
    }
    return current.fallbackUrls[key];
  }

  /// Busca en Commons el logo de una marca que no lo tiene en el conjunto actual.
  void ensureLogo(String brandName) {
    final resolver = _resolveCommonsLogo;
    if (resolver == null) return;
    final key = _keyFor(brandName);
    final current = state;
    if (current is! BrandLogosLoaded) {
      _pending[key] = brandName;
      return;
    }
    final hasSetLogo =
        !_brandsWithoutLogo.contains(key) && current.logoUrls[key] != null;
    if (hasSetLogo || !_requested.add(key)) return;
    unawaited(_fetchFallback(resolver, brandName, key));
  }

  Future<void> _fetchFallback(
    ResolveCommonsLogoUseCase resolver,
    String brandName,
    String key,
  ) async {
    try {
      final logo = await resolver(_resolveAlias(brandName));
      final current = state;
      if (logo == null || isClosed || current is! BrandLogosLoaded) return;
      emit(
        BrandLogosLoaded(
          current.logoUrls,
          fallbackUrls: {...current.fallbackUrls, key: logo.url},
        ),
      );
    } on AppFailure {
      // Sin red se podrá reintentar la próxima vez que se pida la marca.
      _requested.remove(key);
    }
  }

  String _keyFor(String brandName) =>
      TextNormalizer.normalize(_resolveAlias(brandName));

  // Aplica el alias de la marca, ignorando mayúsculas y acentos.
  String _resolveAlias(String brandName) {
    final normalized = TextNormalizer.normalize(brandName);
    for (final alias in LogosConfig.brandAliases.entries) {
      if (TextNormalizer.normalize(alias.key) == normalized) return alias.value;
    }
    return brandName;
  }
}
