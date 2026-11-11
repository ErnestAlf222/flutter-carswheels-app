import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/catalog_state.dart';

/// Carga las marcas del año más reciente y maneja el carrusel.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({
    required this.getLatestYear,
    required this.getBrands,
    this.minimumLoadingTime = const Duration(
      milliseconds: UiConfig.loaderMinimumVisibleMilliseconds,
    ),
  }) : super(const CatalogInitial());

  final GetLatestYearUseCase getLatestYear;
  final GetBrandsUseCase getBrands;

  /// Tiempo mínimo que el estado loading permanece visible.
  final Duration minimumLoadingTime;

  Future<void> loadBrands() async {
    if (state is CatalogLoading) return;
    final loadingTimer = Stopwatch()..start();
    emit(const CatalogLoading());
    try {
      final years = await getLatestYear.availableYears();
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

  /// Cambia de año y recarga las marcas; ignora años no disponibles.
  Future<void> selectYear(int year) async {
    final current = state;
    if (current is! CatalogLoaded || year == current.year) return;
    if (!current.availableYears.contains(year)) return;
    final previousBrand = current.brands.isEmpty
        ? null
        : TextNormalizer.normalize(current.brands[current.selectedIndex].name);
    final loadingTimer = Stopwatch()..start();
    emit(const CatalogLoading());
    try {
      final brands = await getBrands(year);
      await _waitMinimumLoading(loadingTimer);
      final keptIndex = brands.indexWhere(
        (brand) => TextNormalizer.normalize(brand.name) == previousBrand,
      );
      final selectedIndex = keptIndex < 0 ? 0 : keptIndex;
      emit(
        CatalogLoaded(
          year: year,
          brands: brands,
          availableYears: current.availableYears,
          selectedIndex: selectedIndex,
          windowStart: selectedIndex,
        ),
      );
    } on AppFailure catch (failure) {
      await _waitMinimumLoading(loadingTimer);
      emit(CatalogError(failure));
    } catch (error) {
      await _waitMinimumLoading(loadingTimer);
      emit(CatalogError(UnknownFailure(error.toString())));
    }
  }

  /// Pasa al año anterior (más antiguo); se detiene en el extremo.
  Future<void> showPreviousYear() => _moveYear(1);

  /// Pasa al año siguiente (más reciente); se detiene en el extremo.
  Future<void> showNextYear() => _moveYear(-1);

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
