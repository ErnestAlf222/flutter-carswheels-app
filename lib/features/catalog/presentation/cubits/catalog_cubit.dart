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
      milliseconds: UiConfig.loaderMinimumVisibleMilliseconds,
    ),
  }) : super(const CatalogInitial());

  final GetAvailableYearsUseCase getAvailableYears;
  final GetBrandsUseCase getBrands;

  /// Tiempo mínimo que el estado loading permanece visible.
  final Duration minimumLoadingTime;

  // Último estado cargado; sirve de base para reintentar un cambio de año.
  CatalogLoaded? _lastLoaded;

  Future<void> loadBrands() async {
    if (state is CatalogLoading) return;
    final loadingTimer = Stopwatch()..start();
    emit(const CatalogLoading());
    try {
      final years = await getAvailableYears();
      final brands = await getBrands(years.first);
      await _waitMinimumLoading(loadingTimer);
      _emitLoaded(
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
    await _changeYear(current, year);
  }

  /// Repite la última carga que falló; sin año fallido repite loadBrands.
  Future<void> retry() async {
    final current = state;
    if (current is! CatalogError) return;
    final failedYear = current.failedYear;
    final base = _lastLoaded;
    if (failedYear == null || base == null) {
      await loadBrands();
      return;
    }
    await _changeYear(base, failedYear);
  }

  // Carga las marcas de [year] tomando [base] para conservar la marca elegida.
  Future<void> _changeYear(CatalogLoaded base, int year) async {
    if (!base.availableYears.contains(year)) return;
    final previousBrand = base.brands.isEmpty
        ? null
        : TextNormalizer.normalize(base.brands[base.selectedIndex].name);
    final loadingTimer = Stopwatch()..start();
    emit(const CatalogLoading());
    try {
      final brands = await getBrands(year);
      await _waitMinimumLoading(loadingTimer);
      final keptIndex = brands.indexWhere(
        (brand) => TextNormalizer.normalize(brand.name) == previousBrand,
      );
      final selectedIndex = keptIndex < 0 ? 0 : keptIndex;
      _emitLoaded(
        CatalogLoaded(
          year: year,
          brands: brands,
          availableYears: base.availableYears,
          selectedIndex: selectedIndex,
          windowStart: selectedIndex,
        ),
      );
    } on AppFailure catch (failure) {
      await _waitMinimumLoading(loadingTimer);
      emit(CatalogError(failure, failedYear: year));
    } catch (error) {
      await _waitMinimumLoading(loadingTimer);
      emit(CatalogError(UnknownFailure(error.toString()), failedYear: year));
    }
  }

  // Emite un estado cargado y lo recuerda como base de reintento.
  void _emitLoaded(CatalogLoaded loaded) {
    _lastLoaded = loaded;
    emit(loaded);
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
    _emitLoaded(current.copyWith(selectedIndex: index));
  }

  void showPreviousBrands() => _moveWindow(-1);

  void showNextBrands() => _moveWindow(1);

  // Mueve la ventana de uno en uno, de forma circular.
  void _moveWindow(int step) {
    final current = state;
    if (current is! CatalogLoaded || current.brands.isEmpty) return;
    final count = current.brands.length;
    _emitLoaded(
      current.copyWith(windowStart: (current.windowStart + step) % count),
    );
  }

  // Completa el tiempo mínimo de loader pendiente.
  Future<void> _waitMinimumLoading(Stopwatch loadingTimer) async {
    final remaining = minimumLoadingTime - loadingTimer.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
  }
}
