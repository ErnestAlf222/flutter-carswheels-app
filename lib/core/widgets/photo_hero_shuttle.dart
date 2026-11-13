import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/theme/theme.dart';

/// Vuelo de la foto entre la lista y Detalle con las esquinas interpoladas.
class PhotoHeroShuttle {
  const PhotoHeroShuttle._();

  /// Pasa del radio de la lista al de Detalle al ir, y al revés al volver.
  static Widget builder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final hero = toHeroContext.widget as Hero;
    final isPush = direction == HeroFlightDirection.push;
    final begin = isPush ? AppRadii.tile : AppRadii.detailPhotoCard;
    final end = isPush ? AppRadii.detailPhotoCard : AppRadii.tile;
    return AnimatedBuilder(
      animation: animation,
      child: hero.child,
      builder: (context, child) => ClipRRect(
        borderRadius: BorderRadius.circular(
          lerpDouble(begin, end, animation.value) ?? end,
        ),
        child: child,
      ),
    );
  }
}
