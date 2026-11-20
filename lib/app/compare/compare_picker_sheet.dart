import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/app/compare/compare_navigation.dart';
import 'package:cars_wheels_app/app/market_catalog/market_search_context_source.dart';
import 'package:cars_wheels_app/app/market_catalog/search_market_year_selector.dart';
import 'package:cars_wheels_app/app/search_results/search_cubit_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_results_grid.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Abre el selector de vehículo como hoja inferior sobre Comparar.
///
/// Reutiliza SearchPage en modo selección y compacto, con su propio
/// SearchCubit y su propia memoria de scroll: no toca el texto, el alcance,
/// los filtros ni la posición de la pestaña Buscar.
Future<void> showComparePickerSheet(BuildContext context) {
  // Se leen antes de abrir: la hoja vive en el navegador raíz.
  final factory = context.read<SearchCubitFactory>();
  final source = MarketSearchContextSource(
    market: context.read<MarketCubit>(),
    catalog: context.read<CatalogCubit>(),
  );
  return showCompareSheet<void>(
    context,
    maxHeightFraction: CompareConfig.pickerSheetHeightFraction,
    builder: (_) => _ComparePickerSheet(factory: factory, source: source),
  );
}

class _ComparePickerSheet extends StatefulWidget {
  const _ComparePickerSheet({required this.factory, required this.source});

  final SearchCubitFactory factory;
  final MarketSearchContextSource source;

  @override
  State<_ComparePickerSheet> createState() => _ComparePickerSheetState();
}

class _ComparePickerSheetState extends State<_ComparePickerSheet> {
  // Recursos propios del selector; se liberan al cerrar la hoja.
  late final SearchCubit _cubit;
  final ScrollOffsetStore _scrollOffsets = ScrollOffsetStore();

  @override
  void initState() {
    super.initState();
    _cubit = widget.factory.create(widget.source)..requestFocus();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // La hoja conserva su borde superior y se acomoda sobre el teclado.
    final height =
        media.size.height * CompareConfig.pickerSheetHeightFraction -
        media.viewInsets.bottom;
    return RepositoryProvider<ScrollOffsetStore>.value(
      value: _scrollOffsets,
      child: BlocProvider<SearchCubit>.value(
        value: _cubit,
        child: Padding(
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: SizedBox(
            height: height,
            // El teclado ya se descontó: el Scaffold de adentro no lo repite.
            child: MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: Stack(
                children: [
                  ColoredBox(
                    color: AppColors.background,
                    child: SearchPage(
                      title: AppTexts.comparePickerTitle,
                      compact: true,
                      onBack: () => Navigator.of(context).pop(),
                      reserveNavSpace: false,
                      onOpenResult: pickVehicleForCompare,
                      resultsGridBuilder: buildSearchResultsGrid,
                      selectorBuilder: buildSearchMarketYearSelector,
                    ),
                  ),
                  const _SheetNotice(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mensaje breve sobre los resultados cuando el vehículo ya estaba.
class _SheetNotice extends StatelessWidget {
  const _SheetNotice();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompareCubit, CompareState>(
      builder: (context, state) {
        final notice = state is CompareLoaded ? state.notice : null;
        if (notice != CompareNotice.alreadyAdded &&
            notice != CompareNotice.full) {
          return const SizedBox.shrink();
        }
        return Positioned(
          left: UiConfig.pageHorizontalPadding,
          right: UiConfig.pageHorizontalPadding,
          bottom: AppSpacing.m + MediaQuery.paddingOf(context).bottom,
          child: CompareNoticeWidget(
            key: ValueKey((state as CompareLoaded).noticeId),
            notice: notice!,
          ),
        );
      },
    );
  }
}
