import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Pastilla con la versión actual de un vehículo; abre la hoja de versiones.
class CompareVersionPillWidget extends StatelessWidget {
  const CompareVersionPillWidget({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.pill);
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(
            color: AppColors.outline,
            width: UiConfig.cardBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CompareConfig.removeTouchSize,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CompareConfig.versionPillHorizontalPadding,
                vertical: CompareConfig.versionPillVerticalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: CompareConfig.versionPillMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.compareVersionPill,
                    ),
                  ),
                  const SizedBox(width: CompareConfig.versionPillIconGap),
                  const Icon(
                    Symbols.expand_more,
                    size: CompareConfig.versionPillIconSize,
                    color: AppColors.mutedText,
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
