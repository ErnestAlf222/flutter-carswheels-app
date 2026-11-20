import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:cars_wheels_app/app/compare/compare_picker_sheet.dart';
import 'package:cars_wheels_app/app/compare/compare_route_args.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_builder.dart';
import 'package:cars_wheels_app/app/compare/compare_tap_flow.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';

/// "Comparar con otro" de Detalle: agrega el vehículo y va a la pestaña Comparar.
///
/// Usa `go` (no `push`): Comparar es una pestaña del marco, igual que desde el
/// menú; Detalle sale de la pila y volver atrás actúa como en cualquier pestaña.
/// Con exactamente un vehículo, la pantalla abre el selector al llegar. Si el
/// auto ya está o el comparador está lleno, un menú deja sustituir un auto o
/// comparar con otro modelo (que abre el selector).
Future<void> addToCompareFromDetail(
  BuildContext context,
  DetailArgsEntity args,
  String? versionKey,
) async {
  final router = GoRouter.of(context);
  final slot = CompareSlotBuilder.fromDetail(args, versionKey);
  final result = await tapCompareFor(context, slot, announce: false);
  final extra = switch (result.outcome) {
    CompareTapOutcome.dismissed => null,
    CompareTapOutcome.added => CompareRouteArgs(openPicker: result.count == 1),
    CompareTapOutcome.replaced => const CompareRouteArgs(),
    CompareTapOutcome.otherModel => const CompareRouteArgs(openPicker: true),
  };
  if (extra == null) return;
  // `go` saca Detalle de la pila; la hoja del selector, si estaba debajo, se cierra.
  closeComparePickerSheet();
  router.go(RoutesConfig.compare, extra: extra);
}
