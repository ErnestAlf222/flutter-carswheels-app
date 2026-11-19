import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Barra en forma de píldora que lleva a la búsqueda; no es un campo editable.
class HomeSearchBarWidget extends StatelessWidget {
  const HomeSearchBarWidget({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, 0),
      child: Semantics(
        button: true,
        label: AppTexts.searchHomeBarSemanticLabel,
        excludeSemantics: true,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Container(
              height: SearchConfig.homeBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: const Border.fromBorderSide(
                  BorderSide(
                    color: AppColors.outline,
                    width: UiConfig.cardBorderWidth,
                  ),
                ),
                boxShadow: AppShadows.soft,
              ),
              child: Row(
                children: [
                  const Icon(
                    Symbols.search,
                    size: SearchConfig.fieldIconSize,
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      AppTexts.searchHomeBarLabel,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
