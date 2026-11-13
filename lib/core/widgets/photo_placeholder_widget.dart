import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/l10n/l10n.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Qué estado de la foto representa el recuadro.
enum PhotoPlaceholderKind { loading, empty }

/// Recuadro amable para una foto que carga o que no existe.
class PhotoPlaceholderWidget extends StatelessWidget {
  const PhotoPlaceholderWidget({
    super.key,
    required this.kind,
    this.logo,
    this.compact = false,
  });

  final PhotoPlaceholderKind kind;

  /// Logo que se muestra en el estado vacío; sin él se usa el icono del auto.
  final Widget? logo;

  /// Sin textos, para recuadros pequeños.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.tint,
      child: Center(
        child: kind == PhotoPlaceholderKind.loading
            ? _buildLoading(context)
            : _buildEmpty(),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final icon = Icon(
      Symbols.photo_camera,
      size: UiConfig.photoLoadingIconSize,
      color: AppColors.tintText.withValues(
        alpha: UiConfig.photoLoadingIconOpacity,
      ),
    );
    final breathing = MediaQuery.of(context).disableAnimations
        ? icon
        : Pulse(
            infinite: true,
            to: UiConfig.skeletonPulseScale,
            duration: const Duration(
              milliseconds: AnimationConfig.skeletonPulseMilliseconds,
            ),
            child: icon,
          );
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.xs,
      children: [
        breathing,
        if (!compact)
          Text(AppTexts.photoLoadingLabel, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildEmpty() {
    return Semantics(
      label: AppTexts.noPhotoSemanticLabel,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.xs,
        children: [
          logo ??
              const Icon(
                Symbols.directions_car,
                size: UiConfig.photoEmptyLogoSize,
                color: AppColors.tintText,
              ),
          if (!compact)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: [
                  const Icon(
                    Symbols.no_photography,
                    size: UiConfig.photoChipIconSize,
                    color: AppColors.tintText,
                  ),
                  Flexible(
                    child: Text(
                      AppTexts.noPhotoTitle,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
