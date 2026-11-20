import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/compare/compare_navigation.dart';
import 'package:cars_wheels_app/app/market_catalog/market_search_context_source.dart';
import 'package:cars_wheels_app/app/market_catalog/search_market_year_selector.dart';
import 'package:cars_wheels_app/app/search_results/search_cubit_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_results_grid.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Selector de vehículo: la búsqueda en modo selección, con estado propio.
///
/// Reutiliza SearchPage con otro título y otro callback al tocar un resultado,
/// pero con su propio SearchCubit y su propia memoria de scroll: no toca el
/// texto, el alcance, los filtros ni la posición de la pestaña Buscar.
class ComparePickerPage extends StatefulWidget {
  const ComparePickerPage({super.key});

  @override
  State<ComparePickerPage> createState() => _ComparePickerPageState();
}

class _ComparePickerPageState extends State<ComparePickerPage> {
  // Recursos propios del selector; se liberan al cerrarlo.
  late final SearchCubit _cubit;
  final ScrollOffsetStore _scrollOffsets = ScrollOffsetStore();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<SearchCubitFactory>().create(
      MarketSearchContextSource(
        market: context.read<MarketCubit>(),
        catalog: context.read<CatalogCubit>(),
      ),
    );
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ScrollOffsetStore>.value(
      value: _scrollOffsets,
      child: BlocProvider<SearchCubit>.value(
        value: _cubit,
        child: ColoredBox(
          color: AppColors.background,
          child: SearchPage(
            title: AppTexts.comparePickerTitle,
            onBack: context.pop,
            reserveNavSpace: false,
            onOpenResult: pickVehicleForCompare,
            resultsGridBuilder: buildSearchResultsGrid,
            selectorBuilder: buildSearchMarketYearSelector,
          ),
        ),
      ),
    );
  }
}
