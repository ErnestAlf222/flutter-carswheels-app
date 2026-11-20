import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/compare/compare_route_args.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// "Comparar con otro" de Detalle: agrega el vehículo y va a la pestaña Comparar.
///
/// Usa `go` (no `push`): Comparar es una pestaña del marco, igual que desde el
/// menú; Detalle sale de la pila y volver atrás actúa como en cualquier pestaña.
/// Con exactamente un vehículo, la pantalla abre el selector al llegar.
Future<void> addToCompareFromDetail(
  BuildContext context,
  DetailArgsEntity args,
  String? versionKey,
) async {
  final router = GoRouter.of(context);
  final result = await context.read<CompareCubit>().add(
    CompareSlotBuilder.fromDetail(args, versionKey),
  );
  router.go(
    RoutesConfig.compare,
    extra: CompareRouteArgs(openPicker: result.selection.length == 1),
  );
}

/// Un resultado tocado en el selector: se agrega y se regresa a Comparar.
///
/// El mensaje de "ya está" o "lleno" lo muestra Comparar al regresar.
Future<void> pickVehicleForCompare(
  BuildContext context,
  SearchResultEntity result,
) async {
  final slot = CompareSlotBuilder.fromResult(result);
  if (slot == null) return;
  final router = GoRouter.of(context);
  await context.read<CompareCubit>().add(slot);
  if (router.canPop()) router.pop();
}
