import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';
import 'package:cars_wheels_app/core/widgets/app_loader_widget.dart';

/// Capa de pantalla completa bajo el menú: fondo sólido y loader centrado.
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
    // Visible, absorbe los toques sobre el contenido; oculto, los deja pasar.
    return AbsorbPointer(
      absorbing: visible,
      child: AnimatedSwitcher(
        duration: duration,
        child: visible
            ? const _LoaderLayer(key: ValueKey('loader'))
            : const SizedBox.shrink(key: ValueKey('empty')),
      ),
    );
  }
}

/// Fondo sólido con el loader centrado, sin recorte ni sombra.
class _LoaderLayer extends StatelessWidget {
  const _LoaderLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: ColoredBox(
        color: AppColors.background,
        child: Center(
          child: SizedBox(
            width: UiConfig.sectionLoaderSize,
            height: UiConfig.sectionLoaderSize,
            child: AppLoader(),
          ),
        ),
      ),
    );
  }
}
