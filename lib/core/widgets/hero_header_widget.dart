import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Encabezado tinta con esquinas inferiores redondeadas y un resplandor amarillo.
class HeroHeaderWidget extends StatelessWidget {
  const HeroHeaderWidget({super.key, required this.child, this.padding});

  final Widget child;

  /// Relleno interno; por defecto el área segura superior más el de config.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    const radius = BorderRadius.vertical(
      bottom: Radius.circular(HeaderConfig.bottomRadius),
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned(
              top: HeaderConfig.glowOffset,
              right: HeaderConfig.glowOffset,
              child: ExcludeSemantics(
                child: Container(
                  width: HeaderConfig.glowSize,
                  height: HeaderConfig.glowSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.headerGlow,
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  padding ??
                  EdgeInsets.only(
                    top: topInset + HeaderConfig.contentTopPadding,
                    bottom: HeaderConfig.contentBottomPadding,
                  ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
