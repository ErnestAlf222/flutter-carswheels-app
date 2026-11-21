import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/compare/compare_route_args.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Cuántos autos más caben en la comparación de cada mercado, leído de lo guardado.
Future<Map<String, int>> favoriteCompareCapacity(BuildContext context) async {
  final observe = context.read<ObserveCompareSelectionUseCase>();
  final capacity = <String, int>{};
  for (final code in MarketConfig.switchOrderCodes) {
    try {
      final selection = await observe(code).first;
      capacity[code] = CompareConfig.maxSlots - selection.length;
    } on Object {
      // Sin lectura se asume el máximo: la comparación rechaza lo que no quepa.
    }
  }
  return capacity;
}

/// Agrega los favoritos elegidos a la comparación de su mercado y va a Comparar.
///
/// Si su mercado difiere del global, lo cambia en sitio con el mismo flujo de
/// siempre (con su animación y aviso). Verdadero si agregó al menos uno.
Future<bool> compareFromFavorites(
  BuildContext context,
  List<FavoriteEntity> favorites,
) async {
  if (favorites.isEmpty) return false;
  final router = GoRouter.of(context);
  final marketCubit = context.read<MarketCubit>();
  final compare = context.read<CompareCubit>();
  final favoritesCubit = context.read<FavoritesCubit>();
  final observe = context.read<ObserveCompareSelectionUseCase>();
  final code = favorites.first.marketCode;
  final market = Market.fromCode(code);
  if (market == null) return false;
  if (marketCubit.market != market) await marketCubit.select(market);
  final current = await observe(code).first;
  final slots = [
    for (final favorite in favorites)
      CompareSlotEntity(
        marketCode: favorite.marketCode,
        year: favorite.year,
        brand: favorite.brand,
        groupKey: CompareSlotBuilder.groupKeyOf(favorite.modelName),
        modelName: favorite.modelName,
      ),
  ];
  final results = <CompareAddResult>[];
  for (final slot in slots) {
    if (current.contains(slot)) continue;
    results.add(await compare.add(slot, announce: false));
  }
  final added = results.whereType<CompareAdded>().length;
  if (added == 0) return false;
  favoritesCubit.announceAddedToCompare(added);
  router.go(
    RoutesConfig.compare,
    extra: CompareRouteArgs(openPicker: current.length + added == 1),
  );
  return true;
}

/// Lleva a la pestaña Comparar sin cambiar nada más.
void goToCompareFromFavorites(BuildContext context) =>
    GoRouter.of(context).go(RoutesConfig.compare);
