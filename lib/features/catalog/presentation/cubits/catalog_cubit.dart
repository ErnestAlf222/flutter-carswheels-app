import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/catalog_state.dart';

/// Carga las marcas del año más reciente y maneja el carrusel.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({
    required this.getAvailableYears,
    required this.getBrands,
    this.preferredYear,
    this.minimumLoadingTime = const Duration(
      milliseconds: UiConfig.initialLoaderMinimumVisibleMilliseconds,
    ),
  }) : super(const CatalogInitial());

  final GetAvailableYearsUseCase getAvailableYears;
  final GetBrandsUseCase getBrands;

  /// Año con el que arranca la carga; sin él, o si no existe, el más reciente.
  final int? Function()? preferredYear;

  // Marca de la última carga inicial: descarta resultados de cargas viejas.
  final Map<String, Object> _latestLoad = {};
  static const String _loadKey = 'load';

  /// Tiempo mínimo del loader en la carga inicial (no en los refrescos).
  final Duration minimumLoadingTime;

  /// Carga inicial: años disponibles y marcas del año preferido o el más reciente.
  /// Con [force] reemplaza una carga en curso (cambio de mercado).
  ///
  /// Con [silent] (al volver la conexión) no pasa por el loader: la pantalla
  /// conserva su error hasta que lleguen los datos.
  Future<void> loadBrands({bool force = false, bool silent = false}) async {
    if (state is CatalogLoading && !force) return;
    final token = Object();
    _latestLoad[_loadKey] = token;
    final loadingTimer = Stopwatch()..start();
    if (!silent) emit(const CatalogLoading());
    try {
      final years = await getAvailableYears();
      final preferred = preferredYear?.call();
      final year = preferred != null && years.contains(preferred)
          ? preferred
          : years.first;
      final brands = await getBrands(year);
      if (!silent) await _waitMinimumLoading(loadingTimer);
      if (_isStale(token)) return;
      emit(
        CatalogLoaded(
          year: year,
          brands: brands,
          availableYears: years,
          windowStart: BrandCarouselFocus.windowStartFor(0, brands.length),
        ),
      );
    } on AppFailure catch (failure) {
      if (silent) return;
      await _waitMinimumLoading(loadingTimer);
      if (_isStale(token)) return;
      emit(CatalogError(failure));
    } catch (error) {
      if (silent) return;
      await _waitMinimumLoading(loadingTimer);
      if (_isStale(token)) return;
      emit(CatalogError(UnknownFailure(error.toString())));
    }
  }

  /// Cambio de mercado: conserva la pantalla y recarga años y marcas en el
  /// lugar. Conserva la marca elegida si existe en el mercado nuevo.
  Future<void> reloadForMarket() async {
    final current = state;
    if (current is! CatalogLoaded) {
      await loadBrands(force: true);
      return;
    }
    final token = Object();
    _latestLoad[_loadKey] = token;
    emit(current.reloading());
    try {
      final years = await getAvailableYears();
      final preferred = preferredYear?.call();
      final year = preferred != null && years.contains(preferred)
          ? preferred
          : years.first;
      final brands = await getBrands(year);
      if (_isStale(token)) return;
      final keptIndex = _indexOfBrand(brands, current);
      emit(
        CatalogLoaded(
          year: year,
          brands: brands,
          availableYears: years,
          selectedIndex: keptIndex,
          windowStart: BrandCarouselFocus.windowStartFor(
            keptIndex,
            brands.length,
          ),
        ),
      );
    } on AppFailure catch (failure) {
      if (_isStale(token)) return;
      emit(CatalogError(failure));
    } catch (error) {
      if (_isStale(token)) return;
      emit(CatalogError(UnknownFailure(error.toString())));
    }
  }

  // Una carga nueva, o el cierre del cubit, deja viejo el resultado pendiente.
  bool _isStale(Object token) => isClosed || _latestLoad[_loadKey] != token;

  /// Cambia de año conservando el contenido; ignora años no disponibles.
  Future<void> selectYear(int year) async {
    final current = state;
    if (current is! CatalogLoaded ||
        current.isRefreshing ||
        current.isReloading) {
      return;
    }
    if (year == current.year || !current.availableYears.contains(year)) return;
    final token = _latestLoad[_loadKey];
    emit(current.refreshing());
    try {
      final brands = await getBrands(year);
      // Si cambió el mercado mientras tanto, este resultado ya no aplica.
      if (_latestLoad[_loadKey] != token) return;
      final keptIndex = _indexOfBrand(brands, current);
      emit(
        CatalogLoaded(
          year: year,
          brands: brands,
          availableYears: current.availableYears,
          selectedIndex: keptIndex,
          windowStart: BrandCarouselFocus.windowStartFor(
            keptIndex,
            brands.length,
          ),
          droppedBrand: _droppedBrand(brands, current),
        ),
      );
    } on AppFailure catch (failure) {
      if (_latestLoad[_loadKey] != token) return;
      emit(current.failedRefresh(year, failure));
    } catch (error) {
      if (_latestLoad[_loadKey] != token) return;
      emit(current.failedRefresh(year, UnknownFailure(error.toString())));
    }
  }

  /// Al volver la conexión: repite una vez la carga que falló, sin loader.
  Future<void> restoreAfterReconnect() async {
    final current = state;
    if (current is CatalogError) {
      await loadBrands(silent: true);
    } else if (current is CatalogLoaded && current.failedYear != null) {
      await selectYear(current.failedYear!);
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

  // Nombre de la marca elegida si el año nuevo no la trae; nulo si sigue ahí.
  String? _droppedBrand(List<BrandEntity> brands, CatalogLoaded base) {
    if (base.brands.isEmpty || brands.isEmpty) return null;
    final previous = base.brands[base.selectedIndex];
    final wanted = TextNormalizer.normalize(previous.name);
    final kept = brands.any(
      (brand) => TextNormalizer.normalize(brand.name) == wanted,
    );
    return kept ? null : previous.name;
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

  /// Marca como seleccionada la marca en [index]; ignora índices inválidos.
  void selectBrand(int index) {
    final current = state;
    if (current is! CatalogLoaded || current.isReloading) return;
    if (index < 0 || index >= current.brands.length) return;
    // La marca elegida pasa al centro del carrusel.
    emit(
      current.copyWith(
        selectedIndex: index,
        windowStart: BrandCarouselFocus.windowStartFor(
          index,
          current.brands.length,
        ),
      ),
    );
  }

  /// Mueve la ventana de marcas para que empiece en [start]; da la vuelta.
  void showBrandsFrom(int start) {
    final current = state;
    if (current is! CatalogLoaded || current.brands.isEmpty) return;
    final wrapped = CircularIndex.wrap(start, current.brands.length);
    if (wrapped == current.windowStart) return;
    emit(current.copyWith(windowStart: wrapped));
  }

  // Completa el tiempo mínimo de loader pendiente.
  Future<void> _waitMinimumLoading(Stopwatch loadingTimer) async {
    final remaining = minimumLoadingTime - loadingTimer.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
  }
}
