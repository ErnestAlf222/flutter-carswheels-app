import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Abre Detalle de un vehículo de la tabla con el mercado y el año de su columna.
///
/// Es un `push` raíz: el mercado y el año globales de la app no cambian.
/// Detalle no recibe versión, así que abre el grupo completo.
Future<void> openCompareSlotInDetail(
  BuildContext context,
  CompareSlotEntity slot,
) async {
  final router = GoRouter.of(context);
  final market = Market.fromCode(slot.marketCode);
  if (market == null) return;
  final getModelGroups = context.read<GetModelGroupsUseCase>();
  // Sin conexión no se espera a la red: Detalle abre sin la lista de variantes.
  final offline = ConnectivityScope.isOfflineNow(context);
  final variants = offline
      ? const <String>[]
      : await _variantsOf(getModelGroups, slot, market);
  if (!context.mounted) return;
  final args = DetailArgsEntity(
    brand: slot.brand,
    groupName: slot.modelName,
    year: slot.year,
    variantNames: variants,
    photo: null,
    heroTag: [
      CompareConfig.detailHeroTagPrefix,
      slot.identity,
    ].join(CompareConfig.identitySeparator),
    market: market,
  );
  await router.push<void>(RoutesConfig.detail, extra: args);
}

// Variantes del catálogo del mercado de la columna; vacías si no se pueden leer.
Future<List<String>> _variantsOf(
  GetModelGroupsUseCase getModelGroups,
  CompareSlotEntity slot,
  Market market,
) async {
  try {
    final groups = await getModelGroups.inMarket(
      market.code,
      slot.year,
      slot.brand,
    );
    final group = groups
        .where((candidate) => candidate.name == slot.modelName)
        .firstOrNull;
    return [
      for (final variant in group?.variants ?? const <ModelEntity>[])
        variant.name,
    ];
  } on Object {
    return const [];
  }
}
