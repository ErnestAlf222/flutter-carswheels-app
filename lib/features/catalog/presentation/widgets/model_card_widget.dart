import 'package:flutter/material.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Tarjeta de un grupo de modelo con su foto, su nombre y sus versiones.
class ModelCardWidget extends StatelessWidget {
  const ModelCardWidget({
    super.key,
    required this.group,
    required this.brand,
    required this.year,
    required this.index,
    this.animateEntry = true,
  });

  final ModelGroupEntity group;
  final String brand;
  final int year;

  /// Posición del modelo en la lista; define el retardo de entrada.
  final int index;

  /// Falso cuando la lista entra completa con su propio fundido.
  final bool animateEntry;

  @override
  Widget build(BuildContext context) {
    final name = group.name;
    final versions = group.variants.length;
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
                  if (versions > 1)
                    Text(
                      AppTexts.versionsCountLabel(versions),
                      style: AppTextStyles.caption,
                    ),
                ],
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
