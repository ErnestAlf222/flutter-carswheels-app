import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';
import 'package:cars_wheels_app/core/widgets/app_loader_widget.dart';

/// Aviso ligero centrado sobre el contenido; no recibe toques.
class SectionLoaderOverlay extends StatelessWidget {
  const SectionLoaderOverlay({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(
            milliseconds: AnimationConfig.sectionLoaderFadeMilliseconds,
          );
    return IgnorePointer(
      child: Center(
        child: AnimatedSwitcher(
          duration: duration,
          child: visible
              ? const _LoaderCircle(key: ValueKey('loader'))
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ),
    );
  }
}

/// Loader recortado en círculo con sombra suave.
class _LoaderCircle extends StatelessWidget {
  const _LoaderCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: ClipOval(
        child: SizedBox(
          width: UiConfig.sectionLoaderSize,
          height: UiConfig.sectionLoaderSize,
          child: AppLoader(),
        ),
      ),
    );
  }
}
