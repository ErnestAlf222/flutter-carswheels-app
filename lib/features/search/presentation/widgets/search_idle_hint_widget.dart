import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Estado inicial sin recientes: lupa grande tenue y una frase amable.
class SearchIdleHintWidget extends StatelessWidget {
  const SearchIdleHintWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UiConfig.pageHorizontalPadding,
        ),
        child: SolidBackgroundWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.search,
                size: SearchConfig.idleIconSize,
                color: AppColors.mutedText.withValues(
                  alpha: SearchConfig.idleIconOpacity,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                AppTexts.searchIdleHint,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
