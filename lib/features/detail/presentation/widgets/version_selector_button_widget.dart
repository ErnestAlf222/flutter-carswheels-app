import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Botón que muestra la versión elegida y abre la lista de versiones.
class VersionSelectorButtonWidget extends StatelessWidget {
  const VersionSelectorButtonWidget({
    super.key,
    required this.versionCount,
    required this.descriptor,
    required this.enabled,
    required this.onTap,
  });

  final int versionCount;
  final String descriptor;

  /// Falso con una sola versión: sin icono y sin respuesta al toque.
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final versionLabel = AppTexts.detailVersionLabel(versionCount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.detailSelectorSideMargin,
        AppSpacing.s,
        UiConfig.detailSelectorSideMargin,
        0,
      ),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: '$versionLabel, $descriptor',
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadii.versionSelector),
            boxShadow: AppShadows.soft,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(AppRadii.versionSelector),
              child: Container(
                height: UiConfig.detailSelectorHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: UiConfig.detailSelectorHorizontalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            versionLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                          Text(
                            descriptor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.infoValue,
                          ),
                        ],
                      ),
                    ),
                    if (enabled)
                      const Icon(
                        Symbols.expand_more,
                        size: UiConfig.iconSize,
                        color: AppColors.subtle,
                      ),
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
