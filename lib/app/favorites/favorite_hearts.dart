import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/app/favorites/favorite_identity_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Corazón de una tarjeta de Inicio: el modelo es del mercado y el año vigentes.
Widget? buildGroupFavoriteHeart(
  BuildContext context,
  String brand,
  int year,
  ModelGroupEntity group,
) {
  final identity = FavoriteIdentityBuilder.of(
    marketCode: context.read<MarketCubit>().market.code,
    year: year,
    brand: brand,
    groupName: group.name,
  );
  return FavoriteHeartButtonWidget(
    key: ValueKey(identity.key),
    identity: identity,
    // Lo que la tarjeta ya sabe sirve para abrir Detalle sin conexión.
    initialSnapshot: FavoriteSnapshotEntity(
      variantNames: [for (final variant in group.variants) variant.name],
    ),
  );
}

/// Corazón de una tarjeta de resultado de búsqueda; nulo si es solo una marca.
Widget? buildResultFavoriteHeart(
  BuildContext context,
  SearchResultEntity result,
) {
  final identity = FavoriteIdentityBuilder.fromResult(result);
  if (identity == null) return null;
  return FavoriteHeartButtonWidget(
    key: ValueKey(identity.key),
    identity: identity,
    initialSnapshot: FavoriteSnapshotEntity(variantNames: result.variantNames),
  );
}

/// Corazón de la barra inferior de Detalle, con el mercado y el año de sus argumentos.
Widget buildDetailFavoriteButton(BuildContext context, DetailArgsEntity args) {
  final photo = args.photo;
  return FavoriteHeartButtonWidget(
    identity: FavoriteIdentityBuilder.fromDetail(args),
    initialSnapshot: FavoriteSnapshotEntity(
      variantNames: args.variantNames,
      photo: photo == null
          ? null
          : FavoritePhotoEntity(
              thumbnailUrl: photo.thumbnailUrl,
              authorName: photo.authorName,
              licenseName: photo.licenseName,
              sourceUrl: photo.sourceUrl,
              isReference: photo.isReference,
              aspectRatio: photo.aspectRatio,
            ),
    ),
    touchSize: UiConfig.detailBottomBarHeight,
    circleSize: UiConfig.detailBottomBarHeight,
    iconSize: UiConfig.iconSize,
    elevated: true,
  );
}
