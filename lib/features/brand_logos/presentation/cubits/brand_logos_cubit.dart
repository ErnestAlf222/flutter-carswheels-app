import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/presentation/cubits/brand_logos_state.dart';

/// Carga las URLs de los logos y las resuelve por nombre de marca.
class BrandLogosCubit extends Cubit<BrandLogosState> {
  BrandLogosCubit(this._repository) : super(const BrandLogosInitial());

  final BrandLogosRepository _repository;

  Future<void> loadLogos() async {
    if (state is BrandLogosLoading) return;
    emit(const BrandLogosLoading());
    try {
      emit(BrandLogosLoaded(await _repository.getLogoUrlsByBrand()));
    } on AppFailure catch (failure) {
      emit(BrandLogosError(failure));
    } catch (error) {
      emit(BrandLogosError(UnknownFailure(error.toString())));
    }
  }

  /// URL del logo de la marca, o null si no hay logo o aún no carga.
  String? urlFor(String brandName) {
    final current = state;
    if (current is! BrandLogosLoaded) return null;
    return current.logoUrls[TextNormalizer.normalize(_resolveAlias(brandName))];
  }

  // Aplica el alias de la marca, ignorando mayúsculas y acentos.
  String _resolveAlias(String brandName) {
    final normalized = TextNormalizer.normalize(brandName);
    for (final alias in LogosConfig.brandAliases.entries) {
      if (TextNormalizer.normalize(alias.key) == normalized) return alias.value;
    }
    return brandName;
  }
}
