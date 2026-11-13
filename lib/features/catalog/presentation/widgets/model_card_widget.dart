import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Tarjeta de un grupo de modelo con su foto, nombre, clase y consumo.
class ModelCardWidget extends StatelessWidget {
  const ModelCardWidget({
    super.key,
    required this.group,
    required this.brand,
    required this.year,
    required this.index,
    this.onTap,
    this.animateEntry = true,
  });

  final ModelGroupEntity group;
  final String brand;
  final int year;

  /// Posición del modelo en la lista; define el retardo de entrada.
  final int index;

  /// Al tocar la tarjeta; sin ella la tarjeta no responde.
  final VoidCallback? onTap;

  /// Falso cuando la lista entra completa con su propio fundido.
  final bool animateEntry;

  @override
  Widget build(BuildContext context) {
    final name = group.name;
    final versions = group.variants.length;
    final summaryKey = context.read<SummariesCubit>().keyFor(brand, name, year);
    final heroTag = context.read<PhotosCubit>().keyFor(
      PhotoRequest(brand: brand, model: name, year: year),
    );
    final card = BlocSelector<SummariesCubit, SummariesState, String?>(
      selector: (state) => state.consumptionLabelFor(summaryKey),
      builder: (context, consumption) => Semantics(
        label: AppTexts.modelSummarySemanticLabel(name, consumption),
        excludeSemantics: true,
        child: _Tappable(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              UiConfig.modelCardLeftPadding,
              AppSpacing.xs,
              UiConfig.modelCardRightPadding,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                ModelPhotoWidget(
                  brand: brand,
                  model: name,
                  year: year,
                  width: UiConfig.modelPhotoWidth,
                  height: UiConfig.modelPhotoHeight,
                  borderRadius: AppRadii.tile,
                  heroTag: heroTag,
                ),
                const SizedBox(width: UiConfig.modelCardGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle,
                      ),
                      ModelClassLineWidget(
                        brand: brand,
                        groupName: name,
                        year: year,
                        versionsCount: versions,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: UiConfig.modelCardGap),
                ModelConsumptionWidget(
                  brand: brand,
                  groupName: name,
                  year: year,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!animateEntry) return card;
    return AnimatedEntryWidget(
      index: index % CatalogConfig.defaultPageSize,
      child: card,
    );
  }
}

/// Fondo de la tarjeta; si hay onTap, toda la tarjeta responde al toque.
class _Tappable extends StatelessWidget {
  const _Tappable({required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.card);
    final callback = onTap;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: radius,
        boxShadow: AppShadows.soft,
      ),
      child: callback == null
          ? child
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: callback,
                borderRadius: radius,
                child: child,
              ),
            ),
    );
  }
}
