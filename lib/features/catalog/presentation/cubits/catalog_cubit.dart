import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/catalog_state.dart';

/// Carga las marcas del año más reciente.
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({required this.getLatestYear, required this.getBrands})
    : super(const CatalogInitial());

  final GetLatestYearUseCase getLatestYear;
  final GetBrandsUseCase getBrands;

  Future<void> loadBrands() async {
    if (state is CatalogLoading) return;
    emit(const CatalogLoading());
    try {
      final year = await getLatestYear();
      final brands = await getBrands(year);
      emit(CatalogLoaded(year: year, brands: brands));
    } on AppFailure catch (failure) {
      emit(CatalogError(failure));
    } catch (error) {
      emit(CatalogError(UnknownFailure(error.toString())));
    }
  }
}
