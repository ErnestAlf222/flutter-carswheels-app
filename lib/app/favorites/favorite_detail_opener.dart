import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/favorites/favorite_photo_mapper.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Abre Detalle con los datos guardados del favorito.
///
/// Usa el mercado y el año del favorito; el mercado y el año globales de la
/// app no cambian.
Future<void> openFavoriteInDetail(
  BuildContext context,
  FavoriteEntity favorite,
) async {
  final router = GoRouter.of(context);
  final market = Market.fromCode(favorite.marketCode);
  if (market == null) return;
  final snapshot = favorite.snapshot;
  final heroTag = context.read<PhotosCubit>().keyFor(
    PhotoRequest(
      brand: favorite.brand,
      model: favorite.modelName,
      year: favorite.year,
    ),
  );
  final photo = snapshot.photo;
  final photoEntity = photo == null
      ? null
      : favoritePhotoEntityOf(context, photo);
  final variants = await _variantsOf(context, favorite, market);
  final args = DetailArgsEntity(
    brand: favorite.brand,
    groupName: favorite.modelName,
    year: favorite.year,
    variantNames: variants,
    photo: photoEntity,
    heroTag: heroTag,
    market: market,
  );
  await router.push<void>(RoutesConfig.detail, extra: args);
}

// Las variantes del catálogo del mercado del favorito (sin cambiar el global);
// si no se pueden leer, las guardadas.
Future<List<String>> _variantsOf(
  BuildContext context,
  FavoriteEntity favorite,
  Market market,
) async {
  final saved = favorite.snapshot.variantNames;
  // Sin conexión no se espera a la red: se abre con las variantes guardadas.
  if (saved.isNotEmpty && ConnectivityScope.isOfflineNow(context)) return saved;
  final getModelGroups = context.read<GetModelGroupsUseCase>();
  try {
    final groups = await getModelGroups.inMarket(
      market.code,
      favorite.year,
      favorite.brand,
    );
    final group = groups
        .where((candidate) => candidate.name == favorite.modelName)
        .firstOrNull;
    final fresh = [
      for (final variant in group?.variants ?? const <ModelEntity>[])
        variant.name,
    ];
    return fresh.isEmpty ? saved : fresh;
  } on Object {
    return saved;
  }
}
