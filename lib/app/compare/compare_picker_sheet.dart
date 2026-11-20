import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/app/market_catalog/market_search_context_source.dart';
import 'package:cars_wheels_app/app/market_catalog/search_market_year_selector.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_builder.dart';
import 'package:cars_wheels_app/app/compare/compare_tap_flow.dart';
import 'package:cars_wheels_app/app/search_results/search_cubit_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_result_detail_opener.dart';
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
  // Nunca dos hojas del selector a la vez.
  if (_openPickerRoutes.isNotEmpty) return Future<void>.value();
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

// Ruta de la hoja abierta: permite cerrarla desde otro flujo (Detalle apilado).
final List<Route<dynamic>> _openPickerRoutes = [];

/// Cierra la hoja del selector si está abierta; sin efecto si no.
///
/// Evita que quede una hoja huérfana cuando Detalle, abierto sobre ella, lleva
/// a Comparar con `go`.
void closeComparePickerSheet() {
  for (final route in List<Route<dynamic>>.of(_openPickerRoutes)) {
    if (route.isActive) route.navigator?.removeRoute(route);
  }
}

/// Resultado del selector: el botón agrega, la tarjeta abre Detalle.
Widget buildComparePickerResultsGrid(
  BuildContext context,
  List<SearchResultEntity> results,
  String resetKey,
  ValueChanged<SearchResultEntity> onOpen,
) => buildSearchResultsGridWithAction(
  context,
  results,
  resetKey,
  onOpen,
  actionBuilder: _pickerAction,
);

Widget? _pickerAction(BuildContext context, SearchResultEntity result) {
  final slot = CompareSlotBuilder.fromResult(result);
  if (slot == null) return null;
  final name = AppTexts.compareColumnHeaderLabel(slot.brand, slot.modelName);
  return BlocSelector<CompareCubit, CompareState, bool>(
    selector: (state) =>
        state is CompareLoaded &&
        state.selection.slots.any((item) => item.identity == slot.identity),
    builder: (context, isAdded) => ComparePickerButtonWidget(
      vehicleName: name,
      isAdded: isAdded,
      // Ya agregado o comparador lleno: el toque abre el menú de acciones.
      onTap: () => pickVehicleForCompare(context, result),
    ),
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
  Route<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _cubit = widget.factory.create(widget.source)..requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_route != null) return;
    final route = ModalRoute.of(context);
    if (route == null) return;
    _route = route;
    _openPickerRoutes.add(route);
  }

  @override
  void dispose() {
    final route = _route;
    if (route != null) _openPickerRoutes.remove(route);
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
                      onOpenResult: openSearchResultInDetail,
                      resultsGridBuilder: buildComparePickerResultsGrid,
                      selectorBuilder: buildSearchMarketYearSelector,
                      belowHeader:
                          BlocSelector<SearchCubit, SearchState, String>(
                            selector: (state) => state.query,
                            builder: (context, query) =>
                                ComparePickerHintWidget(query: query),
                          ),
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

/// El botón "Comparar" de una tarjeta del selector.
///
/// Con espacio y el auto fuera, se agrega y se cierra la hoja. Si ya estaba o el
/// comparador está lleno, el menú deja sustituir (y se cierra la hoja) o seguir
/// eligiendo otro modelo en la misma hoja.
Future<void> pickVehicleForCompare(
  BuildContext context,
  SearchResultEntity result,
) async {
  final slot = CompareSlotBuilder.fromResult(result);
  if (slot == null) return;
  final navigator = Navigator.of(context, rootNavigator: true);
  final tap = await tapCompareFor(context, slot);
  final done =
      tap.outcome == CompareTapOutcome.added ||
      tap.outcome == CompareTapOutcome.replaced;
  if (done && context.mounted) navigator.pop();
}
