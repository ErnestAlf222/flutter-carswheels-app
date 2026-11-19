import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Chip sobrio de filtro: blanco con borde, o amarillo con texto tinta si está elegido.
class SearchFilterChip extends StatelessWidget {
  const SearchFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.enabled = true,
  });

  final String label;

  /// Resultados de la opción con los demás filtros; nulo si no se cuentan.
  final int? count;
  final bool selected;

  /// Una opción sin resultados se muestra deshabilitada.
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.pill);
    final amount = count;
    return Opacity(
      opacity: enabled ? 1.0 : SearchConfig.filterChipDisabledOpacity,
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: AppTexts.searchFilterChipSemanticLabel(label, amount),
        excludeSemantics: true,
        onTap: enabled ? onTap : null,
        child: Material(
          color: selected ? AppColors.accent : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: selected ? AppColors.accent : AppColors.outline,
              width: SearchConfig.filterChipBorderWidth,
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onTap : null,
            child: Container(
              height: SearchConfig.filterChipHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              // widthFactor 1: el chip mide lo que su contenido, no todo el ancho.
              child: Center(
                widthFactor: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: AppTextStyles.bodyStrong),
                    if (amount != null) ...[
                      const SizedBox(width: SearchConfig.filterChipCountGap),
                      Text(
                        AppTexts.searchFilterNumberLabel(amount),
                        style: AppTextStyles.caption.copyWith(
                          color: selected ? AppColors.ink : AppColors.mutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
