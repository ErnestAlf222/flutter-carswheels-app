import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Botón circular con un icono: blanco con sombra suave, tinta translúcido sobre foto o tinta suave sobre la ola.
class DetailCircleButtonWidget extends StatelessWidget {
  const DetailCircleButtonWidget({
    super.key,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.semanticLabel,
    this.onTap,
    this.onPhoto = false,
    this.onDark = false,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final String semanticLabel;

  /// Nulo mientras el botón no tenga acción.
  final VoidCallback? onTap;

  /// Sobre la foto: círculo tinta translúcido con ícono blanco.
  final bool onPhoto;

  /// Sobre la ola tinta: círculo tinta suave con borde fino e ícono blanco.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: onDark
              ? AppColors.inkSoft
              : onPhoto
              ? AppColors.circleButtonOnPhoto
              : AppColors.surface,
          shape: BoxShape.circle,
          border: onDark
              ? Border.all(
                  color: AppColors.mutedOnDark,
                  width: NavConfig.pillBorderWidth,
                )
              : null,
          boxShadow: onPhoto || onDark ? null : AppShadows.soft,
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                icon,
                size: iconSize,
                color: onPhoto || onDark ? AppColors.onDark : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
