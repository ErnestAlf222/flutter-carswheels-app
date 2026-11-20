import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/compare/compare_picker_sheet.dart';
import 'package:cars_wheels_app/app/compare/compare_route_args.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_builder.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_visuals_builder.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';

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
  // `go` saca Detalle de la pila; la hoja del selector, si estaba debajo, se cierra.
  void goToCompare(CompareRouteArgs extra) {
    closeComparePickerSheet();
    router.go(RoutesConfig.compare, extra: extra);
  }

  // El aviso de "lleno" se omite: lo reemplaza la hoja de elección.
  final result = await cubit.add(slot, announce: false);
  if (result is CompareFull) {
    if (!context.mounted) return;
    final choice = await showCompareFullSheet(
      context,
      current: result.selection.slots,
      incoming: slot,
      visuals: marketCompareSlotVisuals,
      versionLabeler: context.read<CompareVersionLabeler>(),
    );
    if (choice == null) return;
    final replaced = choice.replaced;
    if (replaced == null) {
      await cubit.clearAndAdd(slot);
    } else {
      await cubit.replace(replaced, slot);
    }
    goToCompare(const CompareRouteArgs());
    return;
  }
  goToCompare(CompareRouteArgs(openPicker: result.selection.length == 1));
}
