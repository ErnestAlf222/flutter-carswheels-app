import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Botón principal: píldora amarilla con texto en tinta, más oscura al presionar.
class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;

  /// Versión baja para avisos discretos.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.pill);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColors.accent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.pressed)
                ? AppColors.accentPressed
                : Colors.transparent,
          ),
          child: Container(
            height: compact
                ? UiConfig.compactButtonHeight
                : UiConfig.primaryButtonHeight,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? AppSpacing.m : AppSpacing.xl,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTextStyles.bodyStrong.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
