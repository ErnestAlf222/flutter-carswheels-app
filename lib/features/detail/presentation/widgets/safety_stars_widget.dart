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
                child: _Star(filled: index < stars),
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

/// Estrella: llena es amarilla con contorno tinta; vacía solo el contorno suave.
class _Star extends StatelessWidget {
  const _Star({required this.filled});

  final bool filled;

  // Contorno tinta fino: cuatro sombras sin desenfoque alrededor del glifo.
  static const List<Shadow> _outline = [
    Shadow(color: AppColors.ink, offset: Offset(UiConfig.safetyStarOutline, 0)),
    Shadow(
      color: AppColors.ink,
      offset: Offset(-UiConfig.safetyStarOutline, 0),
    ),
    Shadow(color: AppColors.ink, offset: Offset(0, UiConfig.safetyStarOutline)),
    Shadow(
      color: AppColors.ink,
      offset: Offset(0, -UiConfig.safetyStarOutline),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Icon(
      Symbols.star,
      fill: filled ? 1 : 0,
      size: UiConfig.safetyStarSize,
      color: filled ? AppColors.accent : AppColors.outline,
      shadows: filled ? _outline : null,
    );
  }
}
