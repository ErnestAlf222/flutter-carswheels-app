import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Un texto de un control segmentado; el elegido va en tinta fuerte con una línea debajo.
class FavoritesSegmentWidget extends StatelessWidget {
  const FavoritesSegmentWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        // El ancho del texto manda: la línea de abajo se estira a él.
        child: IntrinsicWidth(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: isSelected
                    ? AppTextStyles.bodyStrong
                    : AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.mutedText,
                      ),
              ),
              const SizedBox(height: FavoritesConfig.filterUnderlineGap),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: const SizedBox(
                  height: FavoritesConfig.filterUnderlineHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
