import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/market_catalog/market_search_detail_args_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Abre Detalle desde un resultado de búsqueda, por la ruta de flujo.
///
/// Es un `push` en el navegador raíz: si se llama desde una hoja, Detalle
/// queda encima y al volver atrás la hoja sigue como estaba.
Future<void> openSearchResultInDetail(
  BuildContext context,
  SearchResultEntity result,
) async {
  final router = GoRouter.of(context);
  final builder = MarketSearchDetailArgsBuilder(
    getModelGroups: context.read<GetModelGroupsUseCase>(),
    currentMarket: () => context.read<MarketCubit>().market,
  );
  final args = await builder.build(result);
  if (args == null || !context.mounted) return;
  await router.push<void>(RoutesConfig.detail, extra: args);
}
