import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Píldora con el año y flechas para ir al año anterior o siguiente.
class YearSelectorWidget extends StatelessWidget {
  const YearSelectorWidget({
    super.key,
    required this.year,
    required this.canShowOlder,
    required this.canShowNewer,
    required this.onOlder,
    required this.onNewer,
  });

  final int year;
  final bool canShowOlder;
  final bool canShowNewer;
  final VoidCallback onOlder;
  final VoidCallback onNewer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CarouselConfig.yearSelectorHeight,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _YearArrow(
            icon: Symbols.chevron_left,
            label: AppTexts.olderYearLabel,
            enabled: canShowOlder,
            onPressed: onOlder,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: CarouselConfig.yearTextMinWidth,
            ),
            child: Text(
              year.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyStrong,
            ),
          ),
          _YearArrow(
            icon: Symbols.chevron_right,
            label: AppTexts.newerYearLabel,
            enabled: canShowNewer,
            onPressed: onNewer,
          ),
        ],
      ),
    );
  }
}

/// Flecha del selector; deshabilitada se atenúa y no responde.
class _YearArrow extends StatelessWidget {
  const _YearArrow({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onPressed : null,
      child: SizedBox(
        width: CarouselConfig.arrowTouchTargetSize,
        height: CarouselConfig.arrowTouchTargetSize,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: Icon(
                icon,
                size: CarouselConfig.arrowIconSize,
                color: enabled
                    ? AppColors.ink
                    : AppColors.subtle.withValues(
                        alpha: CarouselConfig.disabledArrowOpacity,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
