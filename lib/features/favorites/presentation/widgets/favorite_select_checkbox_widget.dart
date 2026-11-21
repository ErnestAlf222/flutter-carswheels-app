import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Casilla circular del modo de selección; ocupa el lugar del corazón.
class FavoriteSelectCheckboxWidget extends StatelessWidget {
  const FavoriteSelectCheckboxWidget({
    super.key,
    required this.selected,
    required this.enabled,
    required this.semanticLabel,
    required this.onTap,
  });

  final bool selected;

  /// Falso cuando el favorito no se puede elegir; la casilla se ve apagada.
  final bool enabled;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : AppMotion.fast;
    return Semantics(
      button: true,
      checked: selected,
      enabled: enabled,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: FavoritesConfig.checkboxTouchSize,
          height: FavoritesConfig.checkboxTouchSize,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: AppMotion.change,
              width: FavoritesConfig.checkboxSize,
              height: FavoritesConfig.checkboxSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.ink : AppColors.surface,
                border: Border.all(
                  color: AppColors.ink,
                  width: FavoritesConfig.checkboxBorderWidth,
                ),
              ),
              // El visto es amarillo sobre tinta: el amarillo solo como ícono sobre fondo oscuro.
              child: selected
                  ? const Icon(
                      Symbols.check,
                      size: FavoritesConfig.checkboxIconSize,
                      color: AppColors.accent,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
