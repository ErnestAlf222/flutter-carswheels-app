import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/app/compare/compare_slot_visuals_builder.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

/// Qué pasó al tocar "Comparar" en un auto.
enum CompareTapOutcome {
  /// Se agregó directo, había espacio.
  added,

  /// Sustituyó a otro auto de la comparación.
  replaced,

  /// Eligió comparar con otro modelo.
  otherModel,

  /// Cerró el menú sin elegir (o ya había uno abierto).
  dismissed,
}

/// Resultado del toque: qué ocurrió y cuántos autos quedaron al agregar.
typedef CompareTapResult = ({CompareTapOutcome outcome, int count});

/// Toque en "Comparar" de un auto: agrega directo si hay espacio; si ya está o
/// la comparación está llena, abre el menú de sustituir u otro modelo.
///
/// [announce] en falso omite el mensaje de agregado (Detalle navega a Comparar).
Future<CompareTapResult> tapCompareFor(
  BuildContext context,
  CompareSlotEntity slot, {
  bool announce = true,
}) async {
  final cubit = context.read<CompareCubit>();
  final state = cubit.state;
  final selection = state is CompareLoaded
      ? state.selection
      : CompareSelectionEntity.empty;
  final present = selection.contains(slot);
  if (!present && !selection.isFull) {
    final result = await cubit.add(slot, announce: announce);
    return (
      outcome: result is CompareAdded
          ? CompareTapOutcome.added
          : CompareTapOutcome.dismissed,
      count: result.selection.length,
    );
  }
  if (!context.mounted) {
    return (outcome: CompareTapOutcome.dismissed, count: selection.length);
  }
  // La hoja es modal: su fondo impide abrir otra encima mientras esté a la vista.
  final choice = await showCompareActionsSheet(
    context,
    current: selection.slots,
    incoming: slot,
    alreadyAdded: present,
    visuals: marketCompareSlotVisuals,
  );
  if (choice == null) {
    return (outcome: CompareTapOutcome.dismissed, count: selection.length);
  }
  final replaced = choice.replaced;
  if (replaced == null) {
    return (outcome: CompareTapOutcome.otherModel, count: selection.length);
  }
  await cubit.replace(replaced, slot);
  return (outcome: CompareTapOutcome.replaced, count: selection.length);
}
