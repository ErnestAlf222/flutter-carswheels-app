import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/app/favorites/favorite_hearts.dart';
import 'package:cars_wheels_app/app/search_results/search_card_cubits_factory.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Acción opcional al pie de la tarjeta de un resultado; nula si no aplica.
typedef SearchResultActionBuilder = Widget? Function(
  BuildContext context,
  SearchResultEntity result,
);

/// Cuadrícula de resultados con la tarjeta de modelo del catálogo (composición).
Widget buildSearchResultsGrid(
  BuildContext context,
  List<SearchResultEntity> results,
  String resetKey,
  ValueChanged<SearchResultEntity> onOpen,
) => buildSearchResultsGridWithAction(
  context,
  results,
  resetKey,
  onOpen,
  // En Buscar cada tarjeta lleva su corazón de favoritos.
  leadingActionBuilder: buildResultFavoriteHeart,
);

/// La misma cuadrícula con una acción al pie de cada tarjeta (selector de Comparar).
Widget buildSearchResultsGridWithAction(
  BuildContext context,
  List<SearchResultEntity> results,
  String resetKey,
  ValueChanged<SearchResultEntity> onOpen, {
  SearchResultActionBuilder? actionBuilder,
  SearchResultActionBuilder? leadingActionBuilder,
}) {
  return SearchCardsScope(
    resetKey: resetKey,
    child: ModelGridSliver(
      showBrandLabel: true,
      reserveActionRow: actionBuilder != null,
      delegate: SliverChildBuilderDelegate((context, index) {
        final result = results[index];
        return _SearchResultCard(
          // Con otra búsqueda las tarjetas se recrean y piden a los cubits nuevos.
          key: ValueKey((resetKey, result)),
          result: result,
          index: index,
          onTap: () => onOpen(result),
          action: actionBuilder?.call(context, result),
          leading: leadingActionBuilder?.call(context, result),
        );
      }, childCount: results.length),
    ),
  );
}

/// Da a las tarjetas sus propios fotos y resúmenes; se reinician al cambiar la clave.
class SearchCardsScope extends StatefulWidget {
  const SearchCardsScope({
    super.key,
    required this.resetKey,
    required this.child,
  });

  final String resetKey;
  final Widget child;

  @override
  State<SearchCardsScope> createState() => _SearchCardsScopeState();
}

class _SearchCardsScopeState extends State<SearchCardsScope> {
  // Recursos cancelables: se reemplazan al reiniciar la búsqueda.
  late PhotosCubit _photos;
  late SummariesCubit _summaries;

  @override
  void initState() {
    super.initState();
    final factory = context.read<SearchCardCubitsFactory>();
    _photos = factory.createPhotos();
    _summaries = factory.createSummaries();
  }

  @override
  void didUpdateWidget(SearchCardsScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetKey == widget.resetKey) return;
    // Lo pendiente de la búsqueda anterior ya no hace falta.
    _photos.cancelPending();
    _summaries.cancelPending();
    final factory = context.read<SearchCardCubitsFactory>();
    final oldPhotos = _photos;
    final oldSummaries = _summaries;
    _photos = factory.createPhotos();
    _summaries = factory.createSummaries();
    oldPhotos.close();
    oldSummaries.close();
  }

  @override
  void dispose() {
    _photos.close();
    _summaries.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PhotosCubit>.value(value: _photos),
        BlocProvider<SummariesCubit>.value(value: _summaries),
      ],
      child: widget.child,
    );
  }
}

/// Tarjeta de un resultado: al mostrarse pide su foto y su resumen.
class _SearchResultCard extends StatefulWidget {
  const _SearchResultCard({
    super.key,
    required this.result,
    required this.index,
    required this.onTap,
    this.action,
    this.leading,
  });

  final SearchResultEntity result;
  final int index;
  final VoidCallback onTap;
  final Widget? action;
  final Widget? leading;

  @override
  State<_SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<_SearchResultCard> {
  @override
  void initState() {
    super.initState();
    // Los cubits cambian de estado después de construir, no durante.
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestData());
  }

  void _requestData() {
    if (!mounted) return;
    final result = widget.result;
    final groupName = result.groupName;
    if (groupName == null) return;
    final photos = context.read<PhotosCubit>();
    final summaries = context.read<SummariesCubit>();
    if (photos.isClosed || summaries.isClosed) return;
    photos.requestPhotos([
      PhotoRequest(brand: result.brand, model: groupName, year: result.year),
    ]);
    summaries.requestSummaries([
      SummaryRequest(
        brand: result.brand,
        groupName: groupName,
        year: result.year,
        variantNames: result.variantNames,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final groupName = result.groupName ?? result.brand;
    return ModelGridCardWidget(
      group: ModelGroupEntity(
        name: groupName,
        variants: [
          for (final name in result.variantNames) ModelEntity(name: name),
        ],
      ),
      brand: result.brand,
      year: result.year,
      index: widget.index,
      onTap: widget.onTap,
      showBrandLabel: true,
      footerAction: widget.action,
      leadingAction: widget.leading,
    );
  }
}
