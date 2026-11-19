import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Selector de mercado y año del encabezado de Buscar, atado al catálogo.
Widget buildSearchMarketYearSelector(BuildContext context) {
  return BlocBuilder<CatalogCubit, CatalogState>(
    builder: (context, state) => MarketYearSelectorWidget(
      years: state is CatalogLoaded ? state.availableYears : const [],
      year: state is CatalogLoaded ? state.year : null,
      onYearSelected: context.read<CatalogCubit>().selectYear,
    ),
  );
}
