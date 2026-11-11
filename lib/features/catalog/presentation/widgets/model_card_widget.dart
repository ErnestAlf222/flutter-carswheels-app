import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Tarjeta de un modelo con su icono y su nombre.
class ModelCardWidget extends StatelessWidget {
  const ModelCardWidget({
    super.key,
    required this.name,
    required this.index,
    this.animateEntry = true,
  });

  final String name;

  /// Posición del modelo en la lista; define el retardo de entrada.
  final int index;

  /// Falso cuando la lista entra completa con su propio fundido.
  final bool animateEntry;

  @override
  Widget build(BuildContext context) {
    final card = Semantics(
      label: name,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: UiConfig.modelThumbnailSize,
              height: UiConfig.modelThumbnailSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(AppRadii.tile),
              ),
              child: const Icon(
                Symbols.directions_car,
                size: UiConfig.iconSize,
                color: AppColors.tintText,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle,
              ),
            ),
          ],
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
