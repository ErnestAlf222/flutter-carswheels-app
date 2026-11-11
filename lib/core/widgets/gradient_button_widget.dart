import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Botón de píldora con el degradado principal.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: AppShadows.accent,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Container(
              height: UiConfig.primaryButtonHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.onGradient,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
