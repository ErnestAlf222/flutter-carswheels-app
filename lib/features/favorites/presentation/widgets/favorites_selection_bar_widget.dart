import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Barra inferior del modo de selección: contador, una nota y el botón "Comparar (N)".
class FavoritesSelectionBarWidget extends StatelessWidget {
  const FavoritesSelectionBarWidget({
    super.key,
    required this.count,
    required this.onCompare,
    this.note,
    this.noteActionLabel,
    this.onNoteAction,
  });

  final int count;

  /// Nula con nada elegido: el botón queda apagado.
  final VoidCallback? onCompare;

  /// Una sola nota a la vez (otro mercado, comparación llena, mínimo de autos).
  final String? note;
  final String? noteActionLabel;
  final VoidCallback? onNoteAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            FavoritesConfig.selectionBarRadius,
          ),
          border: Border.all(
            color: AppColors.outline,
            width: UiConfig.cardBorderWidth,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: FavoritesConfig.selectionBarHorizontalPadding,
            vertical: FavoritesConfig.selectionBarVerticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      count == 0
                          ? FavoritesTexts.selectCarsHint
                          : FavoritesTexts.selectedCount(count),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong,
                    ),
                  ),
                  const SizedBox(width: FavoritesConfig.selectionBarGap),
                  // Sin nada elegido el botón se ve apagado y no responde.
                  Opacity(
                    opacity: onCompare == null
                        ? FavoritesConfig.selectionDimmedOpacity
                        : 1,
                    child: IgnorePointer(
                      ignoring: onCompare == null,
                      child: AccentButton(
                        label: FavoritesTexts.compareAction(count),
                        onPressed: onCompare ?? () {},
                      ),
                    ),
                  ),
                ],
              ),
              if (note != null) ...[
                const SizedBox(height: FavoritesConfig.selectionBarNoteGap),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ),
                    if (noteActionLabel != null)
                      TextButton(
                        onPressed: onNoteAction,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          minimumSize: const Size(
                            0,
                            FavoritesConfig.checkboxTouchSize,
                          ),
                        ),
                        child: Text(
                          noteActionLabel!,
                          style: AppTextStyles.bodyStrong,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
