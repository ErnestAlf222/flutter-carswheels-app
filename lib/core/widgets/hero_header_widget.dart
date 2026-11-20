import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Encabezado de tinta plana con esquinas inferiores redondeadas.
class HeroHeaderWidget extends StatelessWidget {
  const HeroHeaderWidget({
    super.key,
    required this.child,
    this.padding,
    this.includeTopInset = true,
  });

  final Widget child;

  /// Relleno interno; por defecto el área segura superior más el de config.
  final EdgeInsetsGeometry? padding;

  /// Falso cuando una banda fija ya cubre el área segura superior.
  final bool includeTopInset;

  @override
  Widget build(BuildContext context) {
    final topInset = includeTopInset ? MediaQuery.paddingOf(context).top : 0.0;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(HeaderConfig.bottomRadius),
        ),
      ),
      child: Padding(
        padding:
            padding ??
            EdgeInsets.only(
              top: topInset + HeaderConfig.contentTopPadding,
              bottom: HeaderConfig.contentBottomPadding,
            ),
        child: child,
      ),
    );
  }
}
