import 'package:flutter/material.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Tarjeta de un modelo con su foto y su nombre.
class ModelCardWidget extends StatelessWidget {
  const ModelCardWidget({
    super.key,
    required this.name,
    required this.brand,
    required this.year,
    required this.index,
    this.animateEntry = true,
  });

  final String name;
  final String brand;
  final int year;

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
        padding: const EdgeInsets.fromLTRB(
          UiConfig.modelCardLeftPadding,
          AppSpacing.xs,
          UiConfig.modelCardRightPadding,
          AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: AppShadows.soft,
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
            ),
            const SizedBox(width: UiConfig.modelCardGap),
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
