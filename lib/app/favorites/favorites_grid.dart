import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/app/favorites/favorite_card_cubits.dart';
import 'package:cars_wheels_app/app/favorites/favorite_photo_mapper.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Cuadrícula de Favoritos con la tarjeta de modelo del catálogo (composición).
///
/// Las tarjetas se arman con la instantánea guardada: no piden datos a la red.
Widget buildFavoritesGrid(
  BuildContext context,
  List<FavoriteEntity> favorites,
  ValueChanged<FavoriteEntity> onOpen,
  ValueChanged<FavoriteEntity> onRemove,
  FavoritesSelectionView? selection,
) => _FavoritesCardsScope(
  favorites: favorites,
  onOpen: onOpen,
  onRemove: onRemove,
  selection: selection,
);

// Fotos y resúmenes de un mercado: un par de cubits por mercado evita que dos
// favoritos con la misma marca, modelo y año de mercados distintos se pisen.
class _MarketCubits {
  _MarketCubits(this.photos, this.summaries);

  final SnapshotPhotosCubit photos;
  final SnapshotSummariesCubit summaries;
}

/// Da a las tarjetas sus cubits sembrados con la instantánea y los mantiene al día.
class _FavoritesCardsScope extends StatefulWidget {
  const _FavoritesCardsScope({
    required this.favorites,
    required this.onOpen,
    required this.onRemove,
    required this.selection,
  });

  final List<FavoriteEntity> favorites;
  final ValueChanged<FavoriteEntity> onOpen;
  final ValueChanged<FavoriteEntity> onRemove;

  /// Datos del modo de selección; nulo fuera de él.
  final FavoritesSelectionView? selection;

  @override
  State<_FavoritesCardsScope> createState() => _FavoritesCardsScopeState();
}

class _FavoritesCardsScopeState extends State<_FavoritesCardsScope> {
  // Recursos propios: se crean por mercado y se cierran con la pantalla.
  final Map<String, _MarketCubits> _byMarket = {};

  @override
  void initState() {
    super.initState();
    _seed(widget.favorites);
  }

  @override
  void didUpdateWidget(_FavoritesCardsScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seed(widget.favorites);
  }

  @override
  void dispose() {
    for (final cubits in _byMarket.values) {
      unawaited(cubits.photos.close());
      unawaited(cubits.summaries.close());
    }
    super.dispose();
  }

  _MarketCubits _cubitsFor(String marketCode) {
    final existing = _byMarket[marketCode];
    if (existing != null) return existing;
    final factory = context.read<FavoriteCardCubitsFactory>();
    return _byMarket[marketCode] = _MarketCubits(
      factory.createPhotos(),
      factory.createSummaries(),
    );
  }

  // Convierte cada instantánea en los espacios que leen las tarjetas.
  void _seed(List<FavoriteEntity> favorites) {
    final summaries = <String, Map<String, SummarySlot>>{};
    final photos = <String, Map<String, PhotoSlot>>{};
    for (final favorite in favorites) {
      final code = favorite.marketCode;
      final cubits = _cubitsFor(code);
      final snapshot = favorite.snapshot;
      summaries.putIfAbsent(code, () => {})[cubits.summaries.keyFor(
        favorite.brand,
        favorite.modelName,
        favorite.year,
      )] = _summarySlotOf(
        snapshot,
      );
      photos.putIfAbsent(code, () => {})[cubits.photos.keyFor(
        PhotoRequest(
          brand: favorite.brand,
          model: favorite.modelName,
          year: favorite.year,
        ),
      )] = _photoSlotOf(
        snapshot,
      );
    }
    // Un solo cambio de estado por mercado, no uno por tarjeta.
    for (final entry in summaries.entries) {
      _cubitsFor(entry.key).summaries.seed(entry.value);
    }
    for (final entry in photos.entries) {
      _cubitsFor(entry.key).photos.seed(entry.value);
    }
  }

  static SummarySlot _summarySlotOf(FavoriteSnapshotEntity snapshot) {
    final kinds = [
      for (final name in snapshot.engineKinds) ?EngineKind.fromName(name),
    ];
    final hasData =
        snapshot.label != null ||
        kinds.isNotEmpty ||
        snapshot.minKmPerLiter != null;
    if (!hasData) return const SummaryMissing();
    return SummaryFound(
      GroupSummaryEntity(
        vehicleClass: null,
        minKmPerLiter: snapshot.minKmPerLiter,
        maxKmPerLiter: snapshot.maxKmPerLiter,
        hasElectric: kinds.contains(EngineKind.electric),
        hasPluginHybrid: kinds.contains(EngineKind.pluginHybrid),
        hasFuelCell: kinds.contains(EngineKind.hydrogen),
        variantCount: snapshot.variantNames.length,
        engineKinds: kinds,
        // La etiqueta guardada ya está traducida: va donde se muestra tal cual.
        fuelLabel: snapshot.label,
      ),
    );
  }

  PhotoSlot _photoSlotOf(FavoriteSnapshotEntity snapshot) {
    final photo = snapshot.photo;
    if (photo == null) return const PhotoMissing();
    // Con el archivo guardado la tarjeta se ve completa sin conexión.
    return PhotoFound(favoritePhotoEntityOf(context, photo));
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final selection = widget.selection;
    return MasonrySliverWidget<FavoriteEntity>(
      items: widget.favorites,
      keyOf: (favorite) => favorite.key,
      columns: ModelGridConfig.columns,
      spacing: ModelGridConfig.crossAxisSpacing,
      // Cada tarjeta mide lo que su foto: proporción real, limitada al rango.
      heightOf: (favorite, width) => ModelGridMetrics.cellHeight(
        width,
        scaler,
        showBrandLabel: true,
        photoAspectRatio: FavoritePhotoProportion.of(favorite.snapshot.photo),
      ),
      itemBuilder: (context, favorite, index) {
        final cubits = _cubitsFor(favorite.marketCode);
        final selected =
            selection?.selectedKeys.contains(favorite.key) ?? false;
        final dimmed =
            selection != null &&
            !selected &&
            selection.blockOf(favorite) != FavoriteSelectionBlock.none;
        final card = MultiBlocProvider(
          providers: [
            BlocProvider<PhotosCubit>.value(value: cubits.photos),
            BlocProvider<SummariesCubit>.value(value: cubits.summaries),
          ],
          child: ModelGridCardWidget(
            group: ModelGroupEntity(
              name: favorite.modelName,
              variants: [
                for (final name in favorite.snapshot.variantNames)
                  ModelEntity(name: name),
              ],
            ),
            brand: favorite.brand,
            year: favorite.year,
            index: index,
            showBrandLabel: true,
            photoAspectRatio: FavoritePhotoProportion.of(
              favorite.snapshot.photo,
            ),
            onTap: selection == null
                ? () => widget.onOpen(favorite)
                : () => selection.onToggle(favorite),
            // En modo de selección la casilla ocupa el lugar del corazón.
            leadingAction: selection == null
                ? FavoriteHeartButtonWidget(
                    identity: favorite.identity,
                    onTap: () => widget.onRemove(favorite),
                  )
                : FavoriteSelectCheckboxWidget(
                    selected: selected,
                    enabled: !dimmed,
                    semanticLabel: FavoritesTexts.selectCardSemanticLabel(
                      favorite.modelName,
                      selected,
                    ),
                    onTap: () => selection.onToggle(favorite),
                  ),
            photoBadge: FavoriteMarketBadgeWidget(
              marketCode: favorite.marketCode,
              year: favorite.year,
            ),
          ),
        );
        return AnimatedOpacity(
          duration: MediaQuery.of(context).disableAnimations
              ? Duration.zero
              : AppMotion.fast,
          opacity: dimmed ? FavoritesConfig.selectionDimmedOpacity : 1,
          child: card,
        );
      },
    );
  }
}
