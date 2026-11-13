import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Botón circular blanco con un icono y sombra suave.
class DetailCircleButtonWidget extends StatelessWidget {
  const DetailCircleButtonWidget({
    super.key,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.semanticLabel,
    this.onTap,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final String semanticLabel;

  /// Nulo mientras el botón no tenga acción.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
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
              child: Icon(icon, size: iconSize, color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
