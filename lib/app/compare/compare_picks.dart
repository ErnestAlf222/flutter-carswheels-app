import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/app/compare/compare_slot_builder.dart';
import 'package:cars_wheels_app/app/compare/compare_tap_flow.dart';
import 'package:cars_wheels_app/app/search_results/search_picks_row.dart';
import 'package:cars_wheels_app/app/search_results/search_result_detail_opener.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Cuántas sugerencias se piden al índice: sobran para descartar las ya agregadas.
const int comparePicksRequestCount =
    CompareConfig.suggestionsCount + CompareConfig.maxSlots;

/// Las sugerencias sin los autos que ya están en la comparación.
///
/// Un auto cuenta como ya agregado con cualquier versión: misma marca, modelo,
/// mercado y año.
List<SearchResultEntity> picksWithoutCompared(
  List<SearchResultEntity> picks,
  CompareState state,
) {
  final slots = state is CompareLoaded
      ? state.selection.slots
      : const <CompareSlotEntity>[];
  final shown = [
    for (final pick in picks)
      if (!slots.any((slot) => _samePick(slot, pick))) pick,
  ];
  return shown.take(CompareConfig.suggestionsCount).toList();
}

bool _samePick(CompareSlotEntity slot, SearchResultEntity pick) {
  final name = pick.groupName;
  return name != null &&
      slot.marketCode == pick.marketCode &&
      slot.year == pick.year &&
      slot.brand == pick.brand &&
      slot.groupKey == CompareSlotBuilder.groupKeyOf(name);
}

/// Fila de sugerencias del selector: botón "Comparar" por tarjeta.
Widget buildComparePickerPicks(
  BuildContext context,
  List<SearchResultEntity> picks,
  String resetKey,
  ValueChanged<SearchResultEntity> onOpen,
  Widget? Function(BuildContext, SearchResultEntity) actionBuilder,
) => BlocBuilder<CompareCubit, CompareState>(
  builder: (context, state) {
    final shown = picksWithoutCompared(picks, state);
    if (shown.isEmpty) return const SizedBox.shrink();
    return buildSearchPicksRow(
      context,
      shown,
      resetKey,
      onOpen,
      actionBuilder: actionBuilder,
    );
  },
);

/// Arma la sección "Para empezar" de Comparar.
Widget buildComparePicksSection(BuildContext context) =>
    const ComparePicksSection();

/// "Para empezar": sugerencias al azar en Comparar con menos de dos autos.
///
/// Sale del índice de la búsqueda (lo pide si aún no existe); las fotos usan la
/// caché existente. Cada visita a la pestaña trae su propia elección. Sin datos
/// en el índice no muestra nada.
class ComparePicksSection extends StatefulWidget {
  const ComparePicksSection({super.key});

  @override
  State<ComparePicksSection> createState() => _ComparePicksSectionState();
}

class _ComparePicksSectionState extends State<ComparePicksSection> {
  // Semilla de esta visita: otra visita, otra elección.
  final int _seed = Random().nextInt(1 << 30);

  @override
  void initState() {
    super.initState();
    // Pide el índice de Buscar (el mismo, compartido); sin él no hay de dónde sugerir.
    context.read<SearchCubit>().ensureIndex();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      buildWhen: (previous, current) =>
          previous.scope != current.scope ||
          previous.indexStatus != current.indexStatus,
      builder: (context, search) {
        final scope = search.scope;
        final picks = context.read<SearchCubit>().picksFor(
          _seed,
          count: comparePicksRequestCount,
        );
        if (scope == null || picks.isEmpty) return const SizedBox.shrink();
        return BlocBuilder<CompareCubit, CompareState>(
          builder: (context, state) {
            final shown = picksWithoutCompared(picks, state);
            if (shown.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: CompareConfig.startTopGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      UiConfig.pageHorizontalPadding,
                      0,
                      UiConfig.pageHorizontalPadding,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      AppTexts.compareStartTitle,
                      style: AppTextStyles.cardTitle,
                    ),
                  ),
                  buildSearchPicksRow(
                    context,
                    shown,
                    '${scope.key} $_seed',
                    (result) => openSearchResultInDetail(context, result),
                    actionBuilder: _startAction,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// El botón "Comparar" de la entrada: agrega directo (hay espacio de sobra).
Widget? _startAction(BuildContext context, SearchResultEntity result) {
  final slot = CompareSlotBuilder.fromResult(result);
  if (slot == null) return null;
  final name = AppTexts.compareColumnHeaderLabel(slot.brand, slot.modelName);
  return ComparePickerButtonWidget(
    vehicleName: name,
    isAdded: false,
    // La pantalla ya tiene su botón amarillo: este va solo con contorno.
    emphasized: false,
    onTap: () => tapCompareFor(context, slot),
  );
}
