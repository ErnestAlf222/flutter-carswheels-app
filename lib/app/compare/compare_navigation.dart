import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/compare/compare_route_args.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_builder.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_visuals_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// "Comparar con otro" de Detalle: agrega el vehículo y va a la pestaña Comparar.
///
/// Usa `go` (no `push`): Comparar es una pestaña del marco, igual que desde el
/// menú; Detalle sale de la pila y volver atrás actúa como en cualquier pestaña.
/// Con exactamente un vehículo, la pantalla abre el selector al llegar. Con el
/// comparador lleno, una hoja sobre Detalle deja reemplazar, limpiar o cancelar.
Future<void> addToCompareFromDetail(
  BuildContext context,
  DetailArgsEntity args,
  String? versionKey,
) async {
  final router = GoRouter.of(context);
  final cubit = context.read<CompareCubit>();
  final slot = CompareSlotBuilder.fromDetail(args, versionKey);
  // El aviso de "lleno" se omite: lo reemplaza la hoja de elección.
  final result = await cubit.add(slot, announce: false);
  if (result is CompareFull) {
    if (!context.mounted) return;
    final choice = await showCompareFullSheet(
      context,
      current: result.selection.slots,
      incoming: slot,
      visuals: marketCompareSlotVisuals,
    );
    if (choice == null) return;
    final replaced = choice.replaced;
    if (replaced == null) {
      await cubit.clearAndAdd(slot);
    } else {
      await cubit.replace(replaced, slot);
    }
    router.go(RoutesConfig.compare, extra: const CompareRouteArgs());
    return;
  }
  router.go(
    RoutesConfig.compare,
    extra: CompareRouteArgs(openPicker: result.selection.length == 1),
  );
}

/// Un resultado tocado en el selector: se agrega y se cierra la hoja.
///
/// Si el vehículo ya estaba, la hoja sigue abierta con su mensaje breve.
Future<void> pickVehicleForCompare(
  BuildContext context,
  SearchResultEntity result,
) async {
  final slot = CompareSlotBuilder.fromResult(result);
  if (slot == null) return;
  final navigator = Navigator.of(context, rootNavigator: true);
  final added = await context.read<CompareCubit>().add(slot);
  if (added is CompareAdded && context.mounted) navigator.pop();
}
