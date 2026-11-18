import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Fila de estrellas llenas y vacías (de cinco) con una nota corta opcional.
class SafetyStarsWidget extends StatelessWidget {
  const SafetyStarsWidget({super.key, required this.stars, this.note});

  /// Estrellas llenas; el resto se dibuja vacío.
  final int stars;

  /// Nota bajo las estrellas, por ejemplo la cantidad de versiones calificadas.
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int index = 0; index < UiConfig.safetyStarCount; index++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiConfig.safetyStarGap,
                ),
                child: Icon(
                  Symbols.star,
                  fill: index < stars ? 1 : 0,
                  size: UiConfig.safetyStarSize,
                  color: index < stars
                      ? AppColors.starFilled
                      : AppColors.starEmpty,
                ),
              ),
          ],
        ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: UiConfig.safetyNoteTopGap),
            child: Text(
              note!,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ),
      ],
    );
  }
}
