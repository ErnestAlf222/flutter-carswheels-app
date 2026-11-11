import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/catalog_state.dart';

/// Carga las marcas del año más reciente y maneja el carrusel.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({
    required this.getAvailableYears,
    required this.getBrands,
    this.minimumLoadingTime = const Duration(
      milliseconds: UiConfig.initialLoaderMinimumVisibleMilliseconds,
    ),
  }) : super(const CatalogInitial());

  final GetAvailableYearsUseCase getAvailableYears;
  final GetBrandsUseCase getBrands;

  /// Tiempo mínimo del loader en la carga inicial (no en los refrescos).
  final Duration minimumLoadingTime;

  /// Carga inicial: años disponibles y marcas del año más reciente.
  Future<void> loadBrands() async {
    if (state is CatalogLoading) return;
    final loadingTimer = Stopwatch()..start();
    emit(const CatalogLoading());
    try {
      final years = await getAvailableYears();
      final brands = await getBrands(years.first);
      await _waitMinimumLoading(loadingTimer);
      emit(
        CatalogLoaded(year: years.first, brands: brands, availableYears: years),
      );
    } on AppFailure catch (failure) {
      await _waitMinimumLoading(loadingTimer);
      emit(CatalogError(failure));
    } catch (error) {
      await _waitMinimumLoading(loadingTimer);
      emit(CatalogError(UnknownFailure(error.toString())));
    }
  }

  /// Cambia de año conservando el contenido; ignora años no disponibles.
  Future<void> selectYear(int year) async {
    final current = state;
    if (current is! CatalogLoaded || current.isRefreshing) return;
    if (year == current.year || !current.availableYears.contains(year)) return;
    emit(current.refreshing());
    try {
      final brands = await getBrands(year);
      final keptIndex = _indexOfBrand(brands, current);
      emit(
        CatalogLoaded(
          year: year,
          brands: brands,
          availableYears: current.availableYears,
          selectedIndex: keptIndex,
          windowStart: keptIndex,
        ),
      );
    } on AppFailure catch (failure) {
      emit(current.failedRefresh(year, failure));
    } catch (error) {
      emit(current.failedRefresh(year, UnknownFailure(error.toString())));
    }
  }

  /// Repite la carga que falló: el cambio de año o la carga inicial.
  Future<void> retry() async {
    final current = state;
    if (current is CatalogError) {
      await loadBrands();
      return;
    }
    if (current is! CatalogLoaded) return;
    final failedYear = current.failedYear;
    if (failedYear != null) await selectYear(failedYear);
  }

  // Índice de la marca seleccionada en [brands], por nombre; 0 si no existe.
  int _indexOfBrand(List<BrandEntity> brands, CatalogLoaded base) {
    if (base.brands.isEmpty) return 0;
    final previousBrand = TextNormalizer.normalize(
      base.brands[base.selectedIndex].name,
    );
    final index = brands.indexWhere(
      (brand) => TextNormalizer.normalize(brand.name) == previousBrand,
    );
    return index < 0 ? 0 : index;
  }

  /// Pasa al año anterior (más antiguo); se detiene en el extremo.
  Future<void> showOlderYear() => _moveYear(1);

  /// Pasa al año siguiente (más reciente); se detiene en el extremo.
  Future<void> showNewerYear() => _moveYear(-1);

  // Mueve el año dentro de la lista descendente sin dar la vuelta.
  Future<void> _moveYear(int step) async {
    final current = state;
    if (current is! CatalogLoaded) return;
    final targetIndex = current.availableYears.indexOf(current.year) + step;
    if (targetIndex < 0 || targetIndex >= current.availableYears.length) return;
    await selectYear(current.availableYears[targetIndex]);
  }

  /// Marca como seleccionada la marca en [index]; ignora índices inválidos.
  void selectBrand(int index) {
    final current = state;
    if (current is! CatalogLoaded) return;
    if (index < 0 || index >= current.brands.length) return;
    emit(current.copyWith(selectedIndex: index));
  }

  void showPreviousBrands() => _moveWindow(-1);

  void showNextBrands() => _moveWindow(1);

  // Mueve la ventana de uno en uno, de forma circular.
  void _moveWindow(int step) {
    final current = state;
    if (current is! CatalogLoaded || current.brands.isEmpty) return;
    final count = current.brands.length;
    emit(current.copyWith(windowStart: (current.windowStart + step) % count));
  }

  // Completa el tiempo mínimo de loader pendiente.
  Future<void> _waitMinimumLoading(Stopwatch loadingTimer) async {
    final remaining = minimumLoadingTime - loadingTimer.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
  }
}
